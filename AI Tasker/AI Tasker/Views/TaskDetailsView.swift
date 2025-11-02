import SwiftUI
import SwiftData

struct TaskDetailsView: View {
    @Environment(\.modelContext) var modelContext
    var task: TaskLocal

    @State private var taskStatus: String
    @State private var taskCost: String = ""
    @State private var taskDueDate: Date?
    @State private var taskCategory: String = ""
    @State private var inputValues: [String: String] = [:]
    @State private var inputSchema: InputSchemaDefinition?
    @State private var isSaving: Bool = false
    @State private var saveMessage: String?

    let defaultCategories = ["Work", "Personal", "Shopping", "Home", "Health", "Education", "Finance", "Other"]

    var statusIcon: String {
        switch taskStatus {
        case "completed":
            return "checkmark.circle.fill"
        case "in_progress":
            return "progress.indicator"
        default:
            return "circle"
        }
    }

    var statusColor: Color {
        switch taskStatus {
        case "completed":
            return .green
        case "in_progress":
            return .orange
        default:
            return .gray
        }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header with gradient background
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: getTaskIcon(task.type))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.title)
                                    .font(.system(size: 22, weight: .bold))
                                    .lineLimit(2)

                                if let taskDescription = task.taskDescription {
                                    Text(taskDescription)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                            }

                            Spacer()
                        }

                        // Type badge
                        HStack(spacing: 6) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 10))
                            Text(task.type.uppercased())
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(8)
                        .alignmentGuide(.leading) { _ in 0 }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.08),
                                Color.purple.opacity(0.06)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                    Divider()
                        .padding(.vertical, 0)

                    // Main content
                    VStack(spacing: 16) {
                        // Status Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)

                            HStack(spacing: 12) {
                                Image(systemName: statusIcon)
                                    .font(.system(size: 20))
                                    .foregroundColor(statusColor)

                                Menu {
                                    Button(action: { taskStatus = "pending" }) {
                                        HStack {
                                            Image(systemName: "circle")
                                            Text("Pending")
                                        }
                                    }
                                    Button(action: { taskStatus = "in_progress" }) {
                                        HStack {
                                            Image(systemName: "progress.indicator")
                                            Text("In Progress")
                                        }
                                    }
                                    Button(action: { taskStatus = "completed" }) {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text("Completed")
                                        }
                                    }
                                } label: {
                                    Text(taskStatus.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(6)
                                }

                                Spacer()
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)

                        // Cost Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cost")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)

                            HStack(spacing: 8) {
                                Text("$")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blue)
                                TextField("0.00", text: $taskCost)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 16))
                            }
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)

                            Text("Amount to allocate from project budget")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .padding(12)
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)

                        // Due Date Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Due Date")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)

                            DatePicker(
                                "Select date",
                                selection: Binding(
                                    get: { taskDueDate ?? Date() },
                                    set: { taskDueDate = $0 }
                                ),
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)

                            if let dueDate = taskDueDate {
                                Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)

                        // Category Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)

                            Menu {
                                ForEach(defaultCategories, id: \.self) { category in
                                    Button(action: { taskCategory = category }) {
                                        HStack {
                                            Image(systemName: "tag.fill")
                                            Text(category)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if !taskCategory.isEmpty {
                                        Image(systemName: "tag.fill")
                                            .foregroundColor(.blue)
                                        Text(taskCategory)
                                            .foregroundColor(.primary)
                                    } else {
                                        Image(systemName: "tag")
                                            .foregroundColor(.gray)
                                        Text("Select category")
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                            }

                            Text("Organize your task with a category tag")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .padding(12)
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)

                        // Dynamic Input Fields
                        if let schema = inputSchema, let itemSchema = schema.itemSchema {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Task Details")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)

                                ScrollView {
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(itemSchema.fields) { field in
                                            DynamicInputRenderer(
                                                field: field,
                                                value: Binding(
                                                    get: { inputValues[field.name] ?? "" },
                                                    set: { inputValues[field.name] = $0 }
                                                )
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)
                        }

                        Spacer()

                        // Save Button
                        VStack(spacing: 12) {
                            Button(action: saveTaskData) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Save Task")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue,
                                            Color.blue.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(isSaving)

                            if let message = saveMessage {
                                Text(message)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.green)
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadTaskData()
        }
    }

    private func loadTaskData() {
        // Load task status
        taskStatus = task.status

        // Load task cost
        taskCost = task.cost > 0 ? String(format: "%.2f", task.cost) : ""

        // Load task due date
        taskDueDate = task.dueDate

        // Load task category
        taskCategory = task.category ?? ""

        // Load input schema if available
        if let schemaJSON = task.inputSchemaJSON,
           let data = schemaJSON.data(using: .utf8),
           let schema = try? JSONDecoder().decode(InputSchemaDefinition.self, from: data) {
            inputSchema = schema
        }

        // Load existing input values
        if let dataJSON = task.dataJSON,
           let data = dataJSON.data(using: .utf8),
           let dict = try? JSONDecoder().decode([String: String].self, from: data) {
            inputValues = dict
        }
    }

    private func saveTaskData() {
        isSaving = true

        // Update task status
        task.status = taskStatus
        task.updatedAt = Date()

        // Save cost from UI to model
        if let costValue = Double(taskCost.trimmingCharacters(in: .whitespaces)) {
            task.cost = costValue
        } else if taskCost.trimmingCharacters(in: .whitespaces).isEmpty {
            task.cost = 0
        }

        // Save due date from UI to model
        task.dueDate = taskDueDate

        // Save category from UI to model
        task.category = taskCategory.isEmpty ? nil : taskCategory

        // Save input values as JSON
        if let encoded = try? JSONEncoder().encode(inputValues),
           let jsonString = String(data: encoded, encoding: .utf8) {
            task.dataJSON = jsonString
        }

        // Save to model context
        do {
            try modelContext.save()
            saveMessage = "✅ Task saved successfully"
            isSaving = false

            // Clear message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                saveMessage = nil
            }
        } catch {
            saveMessage = "❌ Error saving task"
            isSaving = false
            print("Error saving task: \(error.localizedDescription)")
        }
    }

    init(task: TaskLocal) {
        self.task = task
        _taskStatus = State(initialValue: task.status)
    }

    private func getTaskIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "list":
            return "list.bullet"
        case "text":
            return "doc.text"
        case "number":
            return "number"
        case "currency", "cost":
            return "dollarsign.circle"
        case "date":
            return "calendar"
        case "checkbox":
            return "checkmark.square"
        default:
            return "rectangle.on.rectangle"
        }
    }
}

#Preview {
    let task = TaskLocal(title: "Sample Task", type: "list")
    TaskDetailsView(task: task)
}
