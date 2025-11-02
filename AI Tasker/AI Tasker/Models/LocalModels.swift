import Foundation
import SwiftData

// MARK: - Input Field Definitions

/// Represents a single field definition in an input schema
struct InputFieldDefinition: Codable, Identifiable {
    let name: String
    let label: String
    let type: String // "text", "number", "currency", "date", "checkbox"
    let required: Bool

    var id: String { name }
}

/// Represents the schema for how a task's input should be rendered
struct InputSchemaDefinition: Codable {
    let fieldType: String // "list", "text", "number", "currency", "date", "checkbox"
    let itemSchema: ItemSchema?

    struct ItemSchema: Codable {
        let fields: [InputFieldDefinition]
    }
}

// MARK: - Task Data Models

/// Data structure for list-type tasks
struct ListTaskData: Codable {
    struct ListItem: Codable, Identifiable {
        let id: String
        var values: [String: String] // field name -> value
    }
    var items: [ListItem] = []
}

/// Data structure for currency-type tasks
struct CurrencyTaskData: Codable {
    var amount: Double = 0
    var currency: String = "USD"
}

/// Data structure for date-type tasks
struct DateTaskData: Codable {
    var date: String? // ISO 8601 format
    var time: String? // HH:mm format
}

/// Data structure for simple text/number tasks
struct SimpleTaskData: Codable {
    var value: String = ""
}

// MARK: - SwiftData Models

/// Represents a user's raw prompt input
@Model
final class PromptLocal {
    @Attribute(.unique) var id: String
    var text: String
    var voiceDataURL: String?
    var createdAt: Date
    var status: String // "pending", "completed", "rejected"

    init(id: String = UUID().uuidString, text: String, voiceDataURL: String? = nil, createdAt: Date = Date(), status: String = "pending") {
        self.id = id
        self.text = text
        self.voiceDataURL = voiceDataURL
        self.createdAt = createdAt
        self.status = status
    }
}

/// Represents a project containing multiple tasks
@Model
final class ProjectLocal {
    @Attribute(.unique) var id: String
    var title: String
    var projectDescription: String?
    var taskCount: Int = 0
    var completedTaskCount: Int = 0
    @Relationship(deleteRule: .cascade, inverse: \TaskLocal.project) var tasks: [TaskLocal] = []

    // M4: Project Management
    var dueDate: Date?
    var budget: Double = 0
    var status: String = "active" // "active", "completed", "archived"

    // M5: Reminders Sync
    var syncedToReminders: Bool = false
    var reminderCalendarId: String? // ID of the Promptodo calendar in Reminders

    var createdAt: Date
    var updatedAt: Date

    init(id: String = UUID().uuidString, title: String, projectDescription: String? = nil, dueDate: Date? = nil, budget: Double = 0, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.projectDescription = projectDescription
        self.dueDate = dueDate
        self.budget = budget
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Computed property for total cost from all tasks
    var totalTaskCost: Double {
        tasks.reduce(0) { $0 + $1.cost }
    }

    // Computed property for remaining budget
    var remainingBudget: Double {
        budget - totalTaskCost
    }

    // Computed property for budget percentage used
    var budgetPercentageUsed: Double {
        budget > 0 ? (totalTaskCost / budget) : 0
    }
}

/// Represents a single task within a project
@Model
final class TaskLocal {
    @Attribute(.unique) var id: String
    var projectId: String
    var title: String
    var taskDescription: String?
    var type: String // "list", "text", "number", "currency", "date", "checkbox"
    var status: String // "pending", "in_progress", "completed"

    /// JSON-encoded input schema (InputSchemaDefinition)
    var inputSchemaJSON: String?

    /// JSON-encoded user input data
    var dataJSON: String?

    var dueDate: Date?
    var cost: Double = 0
    var linkedListId: String? // for linking to list tasks for budget tracking

    // M6+: Categories and Tags
    var category: String? // optional category/tag for task organization

    // M5: Reminders Sync
    var reminderId: String? // Apple Reminders event identifier

    var createdAt: Date
    var updatedAt: Date

    var project: ProjectLocal?

    init(
        id: String = UUID().uuidString,
        projectId: String = "",
        title: String,
        taskDescription: String? = nil,
        type: String = "text",
        status: String = "pending",
        inputSchemaJSON: String? = nil,
        dataJSON: String? = nil,
        dueDate: Date? = nil,
        category: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.projectId = projectId
        self.title = title
        self.taskDescription = taskDescription
        self.type = type
        self.status = status
        self.inputSchemaJSON = inputSchemaJSON
        self.dataJSON = dataJSON
        self.dueDate = dueDate
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - API / ChatGPT Models

/// Represents a question card shown to the user
struct QuestionCard: Identifiable {
    let id: UUID = UUID()
    let index: Int
    let text: String
}

/// Represents a task generated by ChatGPT (before user accepts/rejects)
struct GeneratedTaskModel: Identifiable {
    let id: UUID = UUID()
    let title: String
    let description: String
    let type: String // "list", "text", "number", "currency", "date"
    let inputFields: [InputFieldDefinition]
    var isAccepted: Bool = true
}
