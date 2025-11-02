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
                Based on this prompt and answers, generate a comprehensive, detailed list of actionable tasks:

                Prompt: "\(prompt)"

                Answers:
                \(answersText)

                IMPORTANT GUIDELINES:
                1. Generate 5-8 detailed tasks (more than the minimum)
                2. Use LIST tasks for anything involving:
                   - Guest lists, attendee lists, invitee names
                   - Shopping lists, groceries, supplies, inventory
                   - Menu items, food/drink selections
                   - Vendor lists, contact lists
                   - Subtask checklists, activity lists
                   - Items to pack, purchase, or collect
                   - Names, locations, or items to track
                3. Use appropriate field types:
                   - "list": When user needs to track multiple items or names
                   - "text": Single-line descriptions, decisions, notes
                   - "currency": Budget, cost, price information
                   - "date": Deadlines, scheduling, timing
                   - "number": Quantities, counts, measurements
                   - "checkbox": Binary decisions or confirmations
                4. For LIST tasks, include detailed fields for each item:
                   - For guest lists: Include fields like "Name", "Email", "Phone", "Dietary Restrictions"
                   - For shopping: Include fields like "Item", "Quantity", "Price", "Category"
                   - For menus: Include fields like "Dish Name", "Type", "Servings", "Cost"
                5. Make descriptions specific and outcome-focused
                6. Break complex tasks into logical subtasks

                Return ONLY valid JSON in this format (no markdown, no extra text):
                {
                  "projectTitle": "Project Name",
                  "projectDescription": "2-3 sentence description of the project scope",
                  "tasks": [
                    {
                      "title": "Task Title",
                      "description": "Detailed description of what to accomplish and why",
                      "type": "list|text|currency|date|number|checkbox",
                      "inputFields": [
                        {"name": "field_name", "label": "Display Label", "type": "text|number|currency|date", "required": true}
                      ]
                    }
                  ]
                }

                EXAMPLE for party planning:
                {
                  "projectTitle": "Birthday Party Planning",
                  "projectDescription": "Plan and execute a birthday party with catering, decorations, and invitations",
                  "tasks": [
                    {
                      "title": "Create Guest List",
                      "description": "Build comprehensive guest list with contact information for follow-up and coordination",
                      "type": "list",
                      "inputFields": [
                        {"name": "guest_name", "label": "Guest Name", "type": "text", "required": true},
                        {"name": "email", "label": "Email", "type": "text", "required": false},
                        {"name": "phone", "label": "Phone", "type": "text", "required": false},
                        {"name": "dietary_restrictions", "label": "Dietary Restrictions", "type": "text", "required": false}
                      ]
                    },
                    {
                      "title": "Plan Menu",
                      "description": "Select menu items and quantities based on guest count and preferences",
                      "type": "list",
                      "inputFields": [
                        {"name": "dish_name", "label": "Dish Name", "type": "text", "required": true},
                        {"name": "type", "label": "Type (Appetizer/Main/Dessert)", "type": "text", "required": true},
                        {"name": "servings", "label": "Servings Needed", "type": "number", "required": true},
                        {"name": "cost_per_serving", "label": "Cost Per Serving", "type": "currency", "required": true}
                      ]
                    },
                    {
                      "title": "Set Party Budget",
                      "description": "Determine total budget allocation across catering, decorations, and entertainment",
                      "type": "currency",
                      "inputFields": []
                    },
                    {
                      "title": "Decoration Shopping List",
                      "description": "List all decorations needed to create party atmosphere",
                      "type": "list",
                      "inputFields": [
                        {"name": "item", "label": "Decoration Item", "type": "text", "required": true},
                        {"name": "quantity", "label": "Quantity", "type": "number", "required": true},
                        {"name": "estimated_cost", "label": "Estimated Cost", "type": "currency", "required": false}
                      ]
                    }
                  ]
                }

                Now generate tasks for the user's prompt. Make them detailed and comprehensive.
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
                "max_tokens": 3500,
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
