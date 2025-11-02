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

    func getCurrentModel() -> String {
        return selectedModel
    }

    func getCurrentStyle() -> String {
        return taskStyle
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
                    let tasks = try self.parseGeneratedTasks(from: content)
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
    func parseGeneratedTasks(from jsonString: String) throws -> [GeneratedTask] {
        guard let data = jsonString.data(using: .utf8) else {
            throw OpenAIError.decodingFailed(NSError(domain: "JSONDecoding", code: -1))
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        if let directArray = try? decoder.decode([GeneratedTask].self, from: data), !directArray.isEmpty {
            return directArray
        }

        if let container = try? decoder.decode(GeneratedTaskContainer.self, from: data),
           let tasks = container.tasksList, !tasks.isEmpty {
            return tasks
        }

        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            throw OpenAIError.decodingFailed(NSError(domain: "JSONParsing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON payload"]))
        }

        if let array = jsonObject as? [[String: Any]] {
            let tasks = mapGeneratedTasks(from: array)
            if !tasks.isEmpty { return tasks }
        } else if let dictionary = jsonObject as? [String: Any] {
            if let singleTask = buildTask(from: dictionary) {
                return [singleTask]
            }
            let nestedArrays = dictionary.values.compactMap { $0 as? [[String: Any]] }
            for array in nestedArrays {
                let tasks = mapGeneratedTasks(from: array)
                if !tasks.isEmpty { return tasks }
            }
        }

        throw OpenAIError.decodingFailed(
            NSError(
                domain: "JSONParsing",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unexpected task JSON format: \(jsonString)"]
            )
        )
    }

    private func mapGeneratedTasks(from array: [[String: Any]]) -> [GeneratedTask] {
        array.compactMap(buildTask)
    }

    private func parseEstimatedTime(from value: Any?) -> Int16 {
        switch value {
        case let intValue as Int:
            return Int16(clamping: intValue)
        case let int16Value as Int16:
            return int16Value
        case let doubleValue as Double:
            guard doubleValue.isFinite else { return 30 }
            let rounded = Int(doubleValue.rounded())
            return Int16(clamping: rounded)
        case let number as NSNumber:
            return Int16(clamping: number.intValue)
        case let stringValue as String:
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if let directInt = Int(trimmed) {
                return Int16(clamping: directInt)
            }
            let digits = trimmed.compactMap { $0.isNumber ? $0 : nil }
            if let combined = Int(String(digits)) {
                return Int16(clamping: combined)
            }
        default:
            break
        }
        return 30
    }

    private func buildTask(from dictionary: [String: Any]) -> GeneratedTask? {
        guard let rawTitle = (dictionary["title"] as? String) ?? (dictionary["name"] as? String) else { return nil }
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return nil }

        let description = (dictionary["description"] as? String)
            ?? (dictionary["details"] as? String)
            ?? (dictionary["summary"] as? String)

        let priorityRaw = ((dictionary["priority"] as? String)
            ?? (dictionary["importance"] as? String)
            ?? "medium").trimmingCharacters(in: .whitespacesAndNewlines)
        let priority = priorityRaw.isEmpty ? "medium" : priorityRaw.lowercased()

        let timeValue = dictionary["estimatedTime"]
            ?? dictionary["duration"]
            ?? dictionary["time"]
            ?? dictionary["minutes"]
            ?? dictionary["estimatedMinutes"]

        return GeneratedTask(
            title: title,
            description: description,
            estimatedTime: parseEstimatedTime(from: timeValue),
            priority: priority
        )
    }
}

// MARK: - Models
struct GeneratedTask: Codable {
    let title: String
    let description: String?
    let estimatedTime: Int16
    let priority: String
}

private struct GeneratedTaskContainer: Decodable {
    let tasks: [GeneratedTask]?
    let items: [GeneratedTask]?
    let data: [GeneratedTask]?
    let results: [GeneratedTask]?
    let taskList: [GeneratedTask]?

    var tasksList: [GeneratedTask]? {
        tasks ?? items ?? data ?? results ?? taskList
    }
}

private extension Int16 {
    init(clamping value: Int) {
        if value > Int(Int16.max) {
            self = Int16.max
        } else if value < Int(Int16.min) {
            self = Int16.min
        } else {
            self = Int16(value)
        }
    }
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
