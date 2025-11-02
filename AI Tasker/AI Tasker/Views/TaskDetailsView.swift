import SwiftUI
import SwiftData

struct TaskDetailsView: View {
    @Environment(\.modelContext) var modelContext
    var task: TaskLocal

    @State private var taskStatus: String
    @State private var inputValues: [String: String] = [:]
    @State private var inputSchema: InputSchemaDefinition?
    @State private var isSaving: Bool = false
    @State private var saveMessage: String?

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
        VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text(task.title)
                    .font(.system(size: 24, weight: .bold))

                if let taskDescription = task.taskDescription {
                    Text(taskDescription)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }

                HStack(spacing: 8) {
                    Label(task.type, systemImage: "tag.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)

                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
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
        .background(Color(.systemBackground))
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadTaskData()
        }
    }

    private func loadTaskData() {
        // Load task status
        taskStatus = task.status

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
}

#Preview {
    let task = TaskLocal(title: "Sample Task", type: "list")
    TaskDetailsView(task: task)
}
