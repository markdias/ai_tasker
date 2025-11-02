//
//  ClarifyingQuestionsManager.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import Foundation

struct ClarifyingQuestion {
    let question: String
    let type: QuestionType
    let options: [String]?

    enum QuestionType {
        case freeText
        case multipleChoice
        case date
        case number
    }
}

struct ProjectBrief {
    let goal: String
    let answers: [String: String]
}

class ClarifyingQuestionsManager {
    static let shared = ClarifyingQuestionsManager()

    private let openAIManager = OpenAIManager.shared

    // MARK: - Generate Clarifying Questions
    func generateClarifyingQuestions(
        goal: String,
        completion: @escaping (Result<[ClarifyingQuestion], ClarifyingQuestionsError>) -> Void
    ) {
        let systemPrompt = """
        You are a helpful project planning assistant. Your job is to ask clarifying questions
        to help users better define their project scope. Generate 3-4 specific, practical questions
        that will help you understand the project better.

        Return a JSON array with this format:
        [
            {
                "question": "What is the date of the party?",
                "type": "date",
                "options": null
            },
            {
                "question": "How many guests are expected?",
                "type": "number",
                "options": null
            },
            {
                "question": "What type of party is it?",
                "type": "multipleChoice",
                "options": ["Birthday", "Wedding", "Corporate", "Casual Gathering", "Other"]
            }
        ]

        Types: freeText, multipleChoice, date, number
        """

        let userPrompt = """
        Goal: \(goal)

        Please generate clarifying questions to help better plan this project.
        """

        let requestBody: [String: Any] = [
            "model": OpenAIManager.shared.getCurrentModel(),
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

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let apiKey = try? KeychainManager.shared.getAPIKey() {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(.noAPIKey))
            return
        }

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

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(.apiError))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let result = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
                if let content = result.choices.first?.message.content {
                    let questions = try self.parseQuestions(from: content)
                    completion(.success(questions))
                } else {
                    completion(.failure(.noContent))
                }
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }.resume()
    }

    // MARK: - Generate Tasks from Answers
    func generateTasksFromAnswers(
        goal: String,
        answers: [String: String],
        completion: @escaping (Result<[GeneratedTask], ClarifyingQuestionsError>) -> Void
    ) {
        let systemPrompt = """
        You are a project planning expert. Create a detailed task list based on the goal and
        the answers provided. Return a JSON array of tasks with this format:
        [
            {
                "title": "Task title",
                "description": "Brief description",
                "estimatedTime": 30,
                "priority": "high"
            }
        ]
        """

        let answersText = answers
            .map { key, value in "\(key): \(value)" }
            .joined(separator: "\n")

        let userPrompt = """
        Goal: \(goal)

        Additional Details:
        \(answersText)

        Please create a comprehensive task list to accomplish this goal.
        """

        let requestBody: [String: Any] = [
            "model": OpenAIManager.shared.getCurrentModel(),
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

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let apiKey = try? KeychainManager.shared.getAPIKey() {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(.noAPIKey))
            return
        }

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

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(.apiError))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let result = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
                if let content = result.choices.first?.message.content {
                    let tasks = try OpenAIManager.shared.parseGeneratedTasks(from: content)
                    completion(.success(tasks))
                } else {
                    completion(.failure(.noContent))
                }
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }.resume()
    }

    // MARK: - Parse Questions
    private func parseQuestions(from jsonString: String) throws -> [ClarifyingQuestion] {
        guard let data = jsonString.data(using: .utf8) else {
            throw ClarifyingQuestionsError.decodingFailed(NSError(domain: "JSON", code: -1))
        }

        if let array = try? JSONDecoder().decode([QuestionDTO].self, from: data) {
            return array.map { dto in
                ClarifyingQuestion(
                    question: dto.question,
                    type: ClarifyingQuestion.QuestionType(rawValue: dto.type) ?? .freeText,
                    options: dto.options
                )
            }
        }

        throw ClarifyingQuestionsError.decodingFailed(NSError(domain: "JSON", code: -1))
    }

}

// MARK: - DTOs
private struct QuestionDTO: Decodable {
    let question: String
    let type: String
    let options: [String]?
}

private struct ChatCompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message

        struct Message: Decodable {
            let content: String
        }
    }
}

private extension ClarifyingQuestion.QuestionType {
    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "freetext": self = .freeText
        case "multiplechoice": self = .multipleChoice
        case "multiple_choice": self = .multipleChoice
        case "multiple choice": self = .multipleChoice
        case "date": self = .date
        case "number": self = .number
        case "free_text": self = .freeText
        case "free text": self = .freeText
        default: return nil
        }
    }
}

// MARK: - Errors
enum ClarifyingQuestionsError: LocalizedError {
    case noAPIKey
    case networkError(Error)
    case apiError
    case noData
    case noContent
    case encodingFailed
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key not configured"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError:
            return "API error occurred"
        case .noData:
            return "No data received"
        case .noContent:
            return "No content in response"
        case .encodingFailed:
            return "Failed to encode request"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
