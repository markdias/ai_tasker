import Foundation

/// Service for interacting with OpenAI ChatGPT API
class OpenAIService {
    static let shared = OpenAIService()

    private let baseURL = "https://api.openai.com/v1"
    private let model = "gpt-4-turbo"

    private var apiKey: String? {
        KeychainManager.shared.retrieveAPIKey()
    }

    // MARK: - Question Generation

    /// Generate 5 clarifying questions based on a prompt
    func generateQuestions(
        for prompt: String,
        completion: @escaping ([QuestionCard]?, Error?) -> Void
    ) {
        guard let apiKey = apiKey else {
            completion(nil, OpenAIError.missingAPIKey)
            return
        }

        let messages: [[String: String]] = [
            [
                "role": "user",
                "content": """
                Generate exactly 5 clarifying questions for this prompt: "\(prompt)"

                Return ONLY valid JSON in this format (no markdown, no extra text):
                {
                  "questions": [
                    {"index": 1, "text": "Question 1?"},
                    {"index": 2, "text": "Question 2?"},
                    {"index": 3, "text": "Question 3?"},
                    {"index": 4, "text": "Question 4?"},
                    {"index": 5, "text": "Question 5?"}
                  ]
                }
                """
            ]
        ]

        makeRequest(
            endpoint: "/chat/completions",
            apiKey: apiKey,
            body: [
                "model": model,
                "messages": messages,
                "temperature": 0.7,
                "max_tokens": 500,
            ]
        ) { [weak self] data, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, OpenAIError.noData)
                return
            }

            do {
                let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)

                if let content = response.choices.first?.message.content {
                    let questions = try self?.parseQuestions(from: content) ?? []
                    completion(questions, nil)
                } else {
                    completion(nil, OpenAIError.invalidResponse)
                }
            } catch {
                completion(nil, OpenAIError.decodingError(error))
            }
        }
    }

    // MARK: - Task Generation

    /// Generate structured tasks based on prompt and answers
    func generateTasks(
        for prompt: String,
        answers: [String],
        completion: @escaping ([GeneratedTaskModel]?, String?, Error?) -> Void
    ) {
        guard let apiKey = apiKey else {
            completion(nil, nil, OpenAIError.missingAPIKey)
            return
        }

        let answersText = answers.enumerated().map { "Q\($0 + 1): \($1)" }.joined(separator: "\n")

        let messages: [[String: String]] = [
            [
                "role": "user",
                "content": """
                Based on this prompt and answers, generate a structured list of actionable tasks:

                Prompt: "\(prompt)"

                Answers:
                \(answersText)

                Return ONLY valid JSON in this format (no markdown, no extra text):
                {
                  "projectTitle": "Project Name",
                  "projectDescription": "Brief description",
                  "tasks": [
                    {
                      "title": "Task 1",
                      "description": "What needs to be done",
                      "type": "list",
                      "inputFields": [
                        {"name": "field1", "label": "Field Label", "type": "text", "required": true}
                      ]
                    }
                  ]
                }

                Types can be: list, text, number, currency, date, checkbox
                Generate 3-5 tasks. Make them specific and actionable.
                """
            ]
        ]

        makeRequest(
            endpoint: "/chat/completions",
            apiKey: apiKey,
            body: [
                "model": model,
                "messages": messages,
                "temperature": 0.7,
                "max_tokens": 2000,
            ]
        ) { [weak self] data, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }

            guard let data = data else {
                completion(nil, nil, OpenAIError.noData)
                return
            }

            do {
                let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)

                if let content = response.choices.first?.message.content {
                    let (tasks, projectTitle) = try self?.parseTasks(from: content) ?? ([], "")
                    completion(tasks, projectTitle, nil)
                } else {
                    completion(nil, nil, OpenAIError.invalidResponse)
                }
            } catch {
                completion(nil, nil, OpenAIError.decodingError(error))
            }
        }
    }

    // MARK: - Private Methods

    private func makeRequest(
        endpoint: String,
        apiKey: String,
        body: [String: Any],
        completion: @escaping (Data?, Error?) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(nil, OpenAIError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(nil, OpenAIError.serializationError(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 400 {
                    let errorData = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    completion(nil, OpenAIError.httpError(httpResponse.statusCode, errorData))
                    return
                }
            }

            completion(data, nil)
        }.resume()
    }

    private func parseQuestions(from jsonString: String) throws -> [QuestionCard] {
        guard let data = jsonString.data(using: .utf8) else {
            throw OpenAIError.invalidJSON
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(QuestionsResponse.self, from: data)
        return response.questions.map { QuestionCard(index: $0.index, text: $0.text) }
    }

    private func parseTasks(from jsonString: String) throws -> ([GeneratedTaskModel], String) {
        guard let data = jsonString.data(using: .utf8) else {
            throw OpenAIError.invalidJSON
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(TasksResponse.self, from: data)

        let tasks = response.tasks.map { task in
            GeneratedTaskModel(
                title: task.title,
                description: task.description,
                type: task.type,
                inputFields: task.inputFields,
                isAccepted: true
            )
        }

        return (tasks, response.projectTitle)
    }
}

// MARK: - Models

struct ChatGPTResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message

        struct Message: Codable {
            let content: String
        }
    }
}

struct QuestionsResponse: Codable {
    let questions: [QuestionItem]

    struct QuestionItem: Codable {
        let index: Int
        let text: String
    }
}

struct TasksResponse: Codable {
    let projectTitle: String
    let projectDescription: String?
    let tasks: [TaskItem]

    struct TaskItem: Codable {
        let title: String
        let description: String
        let type: String
        let inputFields: [InputFieldDefinition]
    }
}

// MARK: - Errors

enum OpenAIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case noData
    case invalidResponse
    case invalidJSON
    case decodingError(Error)
    case serializationError(Error)
    case httpError(Int, String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key not found in Keychain. Please add your API key in settings."
        case .invalidURL:
            return "Invalid API endpoint URL."
        case .noData:
            return "No data received from OpenAI API."
        case .invalidResponse:
            return "Invalid response format from OpenAI API."
        case .invalidJSON:
            return "Failed to parse JSON response."
        case .decodingError(let error):
            return "Failed to decode API response: \(error.localizedDescription)"
        case .serializationError(let error):
            return "Failed to serialize request: \(error.localizedDescription)"
        case .httpError(let statusCode, let details):
            return "HTTP Error \(statusCode): \(details)"
        }
    }
}
