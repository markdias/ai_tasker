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
        to help users better define their project scope. Generate EXACTLY 5 specific, practical questions
        that will help you understand the project better.

        Return a JSON array with exactly 5 questions in this format:
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
            },
            {
                "question": "What is your budget?",
                "type": "freeText",
                "options": null
            },
            {
                "question": "What are the main activities or focus?",
                "type": "freeText",
                "options": null
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
        You are an expert project planning assistant. Create a detailed, comprehensive task list
        based on the user's goal and answers to clarifying questions. Generate 15-30 specific,
        actionable tasks that cover all aspects needed to accomplish the goal.

        Return a JSON array of tasks with this exact format:
        {
            "tasks": [
                {
                    "title": "Task title",
                    "description": "Brief description",
                    "estimatedTime": 30,
                    "priority": "high"
                },
                ...
            ]
        }

        Guidelines:
        - Each task should be specific and actionable
        - Distribute priorities: some high, some medium, some low
        - Estimated time should be in minutes (15-120 range)
        - Group related tasks logically
        - Include planning, preparation, execution, and follow-up tasks
        - Priorities: high, medium, low
        """

        let answersText = answers
            .map { key, value in "\(key): \(value)" }
            .joined(separator: "\n")

        let userPrompt = """
        Goal: \(goal)

        User's Answers to Clarifying Questions:
        \(answersText)

        Please create a comprehensive, detailed task list with 15-30 tasks to accomplish this goal.
        Take into account all the user's answers and create specific tasks based on those details.
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
            throw ClarifyingQuestionsError.decodingFailed(NSError(domain: "JSON", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Invalid UTF-8 payload"
            ]))
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        if let array = try? decoder.decode([QuestionDTO].self, from: data), !array.isEmpty {
            return array.map(mapQuestionDTO)
        }

        if let container = try? decoder.decode(ClarifyingQuestionContainer.self, from: data),
           let questions = container.questionsList, !questions.isEmpty {
            return questions.map(mapQuestionDTO)
        }

        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            throw ClarifyingQuestionsError.decodingFailed(NSError(domain: "JSON", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to parse ClarifyingQuestions JSON"
            ]))
        }

        if let array = jsonObject as? [[String: Any]] {
            let questions = mapQuestionDictionaries(array)
            if !questions.isEmpty { return questions }
        } else if let dictionary = jsonObject as? [String: Any] {
            if let single = buildQuestion(from: dictionary) {
                return [single]
            }

            let nestedArrays = dictionary.values.compactMap { $0 as? [[String: Any]] }
            for array in nestedArrays {
                let questions = mapQuestionDictionaries(array)
                if !questions.isEmpty { return questions }
            }
        }

        throw ClarifyingQuestionsError.decodingFailed(NSError(domain: "JSON", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Unexpected clarifying question JSON format: \(jsonString)"
        ]))
    }

    private func mapQuestionDTO(_ dto: QuestionDTO) -> ClarifyingQuestion {
        ClarifyingQuestion(
            question: dto.question.trimmingCharacters(in: .whitespacesAndNewlines),
            type: ClarifyingQuestion.QuestionType(rawValue: dto.type) ?? .freeText,
            options: normalizeOptions(dto.options)
        )
    }

}

// MARK: - DTOs
private struct QuestionDTO: Decodable {
    let question: String
    let type: String
    let options: [String]?
}

private struct ClarifyingQuestionContainer: Decodable {
    let questions: [QuestionDTO]?
    let items: [QuestionDTO]?
    let prompts: [QuestionDTO]?
    let data: [QuestionDTO]?

    var questionsList: [QuestionDTO]? {
        questions ?? items ?? prompts ?? data
    }
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

private extension ClarifyingQuestionsManager {
    func mapQuestionDictionaries(_ array: [[String: Any]]) -> [ClarifyingQuestion] {
        array.compactMap(buildQuestion)
    }

    func buildQuestion(from dictionary: [String: Any]) -> ClarifyingQuestion? {
        guard let rawQuestion = dictionary["question"] as? String else { return nil }
        let question = rawQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return nil }

        let rawType = (dictionary["type"] as? String)
            ?? (dictionary["questionType"] as? String)
            ?? "freeText"

        let options = (dictionary["options"] as? [String])
            ?? (dictionary["choices"] as? [String])

        return ClarifyingQuestion(
            question: question,
            type: ClarifyingQuestion.QuestionType(rawValue: rawType) ?? .freeText,
            options: normalizeOptions(options)
        )
    }
}

private extension ClarifyingQuestionsManager {
    func normalizeOptions(_ options: [String]?) -> [String]? {
        guard let options = options else { return nil }
        let cleaned = options
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return cleaned.isEmpty ? nil : cleaned
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
