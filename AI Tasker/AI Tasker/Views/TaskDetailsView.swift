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
    @State private var listTaskData: ListTaskData = ListTaskData()
    @State private var isListTask: Bool = false
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
                        if let schema = inputSchema {
                            if schema.fieldType == "list", let itemSchema = schema.itemSchema {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Task Items")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)

                                    ListTaskTableEditor(
                                        columns: itemSchema.fields,
                                        listData: $listTaskData
                                    )
                                }
                                .padding(12)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(12)
                            } else if let itemSchema = schema.itemSchema {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Task Details")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)

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
                                .padding(12)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(12)
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
        .onChange(of: listTaskData) { _ in
            updateStatusFromListData()
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
            isListTask = schema.fieldType == "list"
        }

        if isListTask {
            if let dataJSON = task.dataJSON,
               let data = dataJSON.data(using: .utf8),
               let listData = try? JSONDecoder().decode(ListTaskData.self, from: data) {
                listTaskData = listData
            } else {
                listTaskData = ListTaskData()
            }
            inputValues = [:]
            updateStatusFromListData()
        } else {
            // Load existing input values for non-list tasks
            if let dataJSON = task.dataJSON,
               let data = dataJSON.data(using: .utf8),
               let dict = try? JSONDecoder().decode([String: String].self, from: data) {
                inputValues = dict
            } else {
                inputValues = [:]
            }
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
        if isListTask {
            let sanitized = sanitizedListData()
            let completionRatio = listCompletionRatio(for: sanitized)

            let derivedStatus: String
            if sanitized.items.isEmpty {
                derivedStatus = "pending"
            } else if completionRatio >= 1.0 {
                derivedStatus = "completed"
            } else {
                derivedStatus = "in_progress"
            }

            task.status = derivedStatus
            task.updatedAt = Date()

            if let encoded = try? JSONEncoder().encode(sanitized),
               let jsonString = String(data: encoded, encoding: .utf8) {
                task.dataJSON = jsonString
            }
        } else {
            if let encoded = try? JSONEncoder().encode(inputValues),
               let jsonString = String(data: encoded, encoding: .utf8) {
                task.dataJSON = jsonString
            }
        }

        task.project?.refreshTaskCounters()

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

    private func sanitizedListData() -> ListTaskData {
        let cleanedItems = listTaskData.items.compactMap { item -> ListTaskData.ListItem? in
            var trimmedValues: [String: String] = [:]
            var hasContent = false

            for (key, value) in item.values {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    hasContent = true
                }
                trimmedValues[key] = trimmed
            }

            return hasContent ? ListTaskData.ListItem(id: item.id, values: trimmedValues, isCompleted: item.isCompleted) : nil
        }

        let sanitized = ListTaskData(items: cleanedItems)
        listTaskData = sanitized
        return sanitized
    }

    private func updateStatusFromListData() {
        guard isListTask else { return }
        let ratio = listCompletionRatio(for: listTaskData)

        if listTaskData.items.isEmpty {
            taskStatus = "pending"
        } else if ratio >= 1.0 {
            taskStatus = "completed"
        } else {
            taskStatus = "in_progress"
        }
    }

    private func listCompletionRatio(for data: ListTaskData) -> Double {
        guard !data.items.isEmpty else { return 0 }
        let completed = data.items.filter { $0.isCompleted }.count
        return Double(completed) / Double(data.items.count)
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

// MARK: - List Task Editor Components

private struct ListTaskTableEditor: View {
    let columns: [InputFieldDefinition]
    @Binding var listData: ListTaskData

    @State private var isPresentingEditor = false
    @State private var editingValues: [String: String] = [:]
    @State private var editingItemId: String?

    private var completionStats: (completed: Int, total: Int, ratio: Double) {
        let total = listData.items.count
        guard total > 0 else { return (0, 0, 0) }
        let completed = listData.items.filter { $0.isCompleted }.count
        let ratio = Double(completed) / Double(total)
        return (completed, total, ratio)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if listData.items.isEmpty {
                emptyState
            } else {
                tableContent
            }

            if completionStats.total > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.0f%%", completionStats.ratio * 100))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                    }

                    ProgressView(value: completionStats.ratio)
                        .progressViewStyle(.linear)
                        .tint(.blue)

                    Text("\(completionStats.completed) of \(completionStats.total) items complete")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(12)
                .background(Color.blue.opacity(0.08))
                .cornerRadius(10)
            }

            Button(action: startAdd) {
                Label("Add Item", systemImage: "plus.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            ListTaskItemEditorSheet(
                columns: columns,
                values: $editingValues,
                isNew: editingItemId == nil,
                onCancel: { isPresentingEditor = false },
                onSave: handleSave
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.on.rectangle.angled")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
            Text("No items yet")
                .font(.system(size: 15, weight: .semibold))
            Text("Tap \"Add Item\" to start building your list.")
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var tableContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                tableHeader
                Divider()
                VStack(spacing: 0) {
                    ForEach(Array(listData.items.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 12) {
                            Button(action: { toggleCompletion(for: index) }) {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(item.isCompleted ? .green : .gray.opacity(0.6))
                            }
                            .buttonStyle(.plain)

                            ForEach(columns) { column in
                                Text(displayText(for: item, column: column))
                                    .font(.system(size: 14))
                                    .foregroundColor(item.isCompleted ? .gray : .primary)
                                    .strikethrough(item.isCompleted, color: .gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 10)
                            }

                            HStack(spacing: 10) {
                                Button(action: { startEdit(item: item) }) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 14, weight: .semibold))
                                }

                                Button(role: .destructive, action: { deleteItem(at: index) }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            .padding(.trailing, 6)
                        }
                        .padding(.horizontal, 12)
                        .background(index.isMultiple(of: 2) ? Color(.systemGray6).opacity(0.65) : Color(.systemBackground))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 12) {
            ForEach(columns) { column in
                Text(column.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
            Text("Actions")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.vertical, 8)
                .padding(.trailing, 8)
        }
        .padding(.horizontal, 12)
    }

    private func displayText(for item: ListTaskData.ListItem, column: InputFieldDefinition) -> String {
        let rawValue = item.values[column.name] ?? ""
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "—" : trimmed
    }

    private func startAdd() {
        editingItemId = nil
        editingValues = defaultValues()
        isPresentingEditor = true
    }

    private func startEdit(item: ListTaskData.ListItem) {
        editingItemId = item.id
        let trimmedValues = item.values.mapValues { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        editingValues = defaultValues().merging(trimmedValues) { _, new in new }
        isPresentingEditor = true
    }

    private func deleteItem(at index: Int) {
        guard index >= 0 && index < listData.items.count else { return }
        listData.items.remove(at: index)
    }

    private func handleSave() {
        let trimmedValues = columns.reduce(into: [String: String]()) { result, column in
            let value = editingValues[column.name] ?? ""
            result[column.name] = value.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let existingId = editingItemId,
           let index = listData.items.firstIndex(where: { $0.id == existingId }) {
            listData.items[index].values = trimmedValues
        } else {
            let newItem = ListTaskData.ListItem(id: UUID().uuidString, values: trimmedValues, isCompleted: false)
            listData.items.append(newItem)
        }

        isPresentingEditor = false
        editingItemId = nil
        editingValues = defaultValues()
    }

    private func toggleCompletion(for index: Int) {
        guard index >= 0 && index < listData.items.count else { return }
        listData.items[index].isCompleted.toggle()
    }

    private func defaultValues() -> [String: String] {
        columns.reduce(into: [String: String]()) { result, column in
            result[column.name] = ""
        }
    }
}

private struct ListTaskItemEditorSheet: View {
    let columns: [InputFieldDefinition]
    @Binding var values: [String: String]
    let isNew: Bool
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                ForEach(columns) { column in
                    Section(column.label) {
                        TextField(
                            column.label,
                            text: Binding(
                                get: { values[column.name] ?? "" },
                                set: { values[column.name] = $0 }
                            )
                        )
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.sentences)
                    }
                }
            }
            .navigationTitle(isNew ? "Add Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        columns.allSatisfy { column in
            guard column.required else { return true }
            let trimmed = (values[column.name] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty
        }
    }
}

#Preview {
    let columns = [
        InputFieldDefinition(name: "guest_name", label: "Guest Name", type: "text", required: true),
        InputFieldDefinition(name: "contact_info", label: "Contact Info", type: "text", required: false),
        InputFieldDefinition(name: "notes", label: "Notes", type: "text", required: false)
    ]

    let schema = InputSchemaDefinition(fieldType: "list", itemSchema: InputSchemaDefinition.ItemSchema(fields: columns))
    let task = TaskLocal(title: "Guest List", taskDescription: "Track guests and contact details", type: "list")
    if let data = try? JSONEncoder().encode(schema) {
        task.inputSchemaJSON = String(data: data, encoding: .utf8)
    }
    return NavigationStack {
        TaskDetailsView(task: task)
            .modelContainer(for: TaskLocal.self, inMemory: true)
    }
}
