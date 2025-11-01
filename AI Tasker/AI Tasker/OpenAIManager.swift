//
//  OpenAIManager.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import Foundation

class OpenAIManager {
    static let shared = OpenAIManager()

    private let apiBaseURL = "https://api.openai.com/v1"
    private let keychainManager = KeychainManager.shared
    private var selectedModel = "gpt-4-turbo"
    private var taskStyle = "detailed"

    // MARK: - Configuration
    func setSelectedModel(_ model: String) {
        selectedModel = model
    }

    func setTaskStyle(_ style: String) {
        taskStyle = style
    }

    // MARK: - Generate Tasks
    func generateTasks(
        goal: String,
        timeAvailable: Int,
        category: String,
        priority: String,
        completion: @escaping (Result<[GeneratedTask], OpenAIError>) -> Void
    ) {
        guard let apiKey = try? keychainManager.getAPIKey() else {
            completion(.failure(.noAPIKey))
            return
        }

        let systemPrompt = """
        You are an expert task planner. When given a goal, break it down into specific, actionable tasks.
        Return the response as a JSON array with the following format:
        [
            {
                "title": "Task title",
                "description": "Brief description of the task",
                "estimatedTime": 30,
                "priority": "high|medium|low"
            }
        ]
        Keep responses concise and practical. Generate between 3-7 tasks depending on complexity.
        """

        let userPrompt = """
        Goal: \(goal)
        Time available: \(timeAvailable) hours
        Category: \(category)
        Priority: \(priority)
        Task style: \(taskStyle)

        Please generate a task list to accomplish this goal.
        """

        let requestBody: [String: Any] = [
            "model": selectedModel,
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": userPrompt
                ]
            ],
            "temperature": 0.7,
            "response_format": ["type": "json_object"]
        ]

        var request = URLRequest(url: URL(string: "\(apiBaseURL)/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(.encodingFailed))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            guard httpResponse.statusCode == 200 else {
                completion(.failure(.apiError(statusCode: httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let result = try JSONDecoder().decode(ChatGPTResponse.self, from: data)

                if let content = result.choices.first?.message.content {
                    let tasks = try self.parseTasks(from: content)
                    completion(.success(tasks))
                } else {
                    completion(.failure(.noContent))
                }
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }.resume()
    }

    // MARK: - Parse Tasks
    private func parseTasks(from jsonString: String) throws -> [GeneratedTask] {
        guard let data = jsonString.data(using: .utf8) else {
            throw OpenAIError.decodingFailed(NSError(domain: "JSONDecoding", code: -1))
        }

        if let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return array.compactMap { dict in
                GeneratedTask(
                    title: dict["title"] as? String ?? "Untitled",
                    description: dict["description"] as? String,
                    estimatedTime: dict["estimatedTime"] as? Int16 ?? 30,
                    priority: dict["priority"] as? String ?? "medium"
                )
            }
        }

        throw OpenAIError.decodingFailed(NSError(domain: "JSONParsing", code: -1))
    }
}

// MARK: - Models
struct GeneratedTask: Codable {
    let title: String
    let description: String?
    let estimatedTime: Int16
    let priority: String
}

struct ChatGPTResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message

        struct Message: Codable {
            let content: String
        }
    }
}

enum OpenAIError: LocalizedError {
    case noAPIKey
    case networkError(Error)
    case invalidResponse
    case apiError(statusCode: Int)
    case noData
    case noContent
    case encodingFailed
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "OpenAI API key not configured"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from API"
        case .apiError(let statusCode):
            return "API error: Status code \(statusCode)"
        case .noData:
            return "No data received from API"
        case .noContent:
            return "No content in API response"
        case .encodingFailed:
            return "Failed to encode request"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
