import SwiftUI
import SwiftData

struct ProjectSettingsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    var project: ProjectLocal

    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date?
    @State private var budget: Double
    @State private var status: String
    @State private var isSaving: Bool = false
    @State private var saveMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                // Project Title
                Section(header: Text("Project Information")) {
                    TextField("Project Title", text: $title)
                        .font(.system(size: 16))

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...)
                        .font(.system(size: 16))
                }

                // Timeline
                Section(header: Text("Timeline")) {
                    Toggle("Set Due Date", isOn: Binding(
                        get: { dueDate != nil },
                        set: { if !$0 { dueDate = nil } }
                    ))

                    if dueDate != nil {
                        DatePicker("Due Date", selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ), displayedComponents: [.date])
                    }
                }

                // Budget
                Section(header: Text("Budget")) {
                    HStack(spacing: 8) {
                        Text("$")
                            .font(.system(size: 16, weight: .semibold))

                        TextField("Budget", value: $budget, format: .number)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 16))
                    }

                    if budget > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Total Cost")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "$%.2f", project.totalTaskCost))
                                    .fontWeight(.semibold)
                            }

                            HStack {
                                Text("Remaining")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "$%.2f", project.remainingBudget))
                                    .fontWeight(.semibold)
                                    .foregroundColor(project.remainingBudget >= 0 ? .green : .red)
                            }

                            // Budget Usage Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.systemGray4))

                                    Capsule()
                                        .fill(project.remainingBudget >= 0 ? Color.blue : Color.red)
                                        .frame(width: geometry.size.width * min(project.budgetPercentageUsed, 1.0))
                                }
                                .frame(height: 8)
                            }
                            .frame(height: 8)

                            Text("\(Int(project.budgetPercentageUsed * 100))% of budget used")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Status
                Section(header: Text("Project Status")) {
                    Picker("Status", selection: $status) {
                        Text("Active").tag("active")
                        Text("Completed").tag("completed")
                        Text("Archived").tag("archived")
                    }
                    .pickerStyle(.segmented)
                }

                // Statistics
                Section(header: Text("Progress")) {
                    HStack {
                        Text("Tasks Completed")
                        Spacer()
                        Text("\(project.completedTaskCount)/\(project.taskCount)")
                            .fontWeight(.semibold)
                    }

                    if project.taskCount > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.systemGray4))

                                    Capsule()
                                        .fill(Color.green)
                                        .frame(width: geometry.size.width * (Double(project.completedTaskCount) / Double(project.taskCount)))
                                }
                                .frame(height: 8)
                            }
                            .frame(height: 8)

                            Text("\(Int(Double(project.completedTaskCount) / Double(project.taskCount) * 100))% complete")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Delete Section
                Section {
                    Button(role: .destructive) {
                        deleteProject()
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete Project")
                        }
                    }
                }
            }
            .navigationTitle("Project Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveProject) {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                    .disabled(isSaving || title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            if let message = saveMessage {
                VStack {
                    Text(message)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.green)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(16)
            }
        }
    }

    private func saveProject() {
        isSaving = true

        project.title = title.trimmingCharacters(in: .whitespaces)
        project.projectDescription = description.trimmingCharacters(in: .whitespaces).isEmpty ? nil : description
        project.dueDate = dueDate
        project.budget = budget
        project.status = status
        project.updatedAt = Date()

        do {
            try modelContext.save()
            saveMessage = "✅ Project saved successfully"
            isSaving = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            saveMessage = "❌ Error saving project"
            isSaving = false
            print("Error saving project: \(error.localizedDescription)")
        }
    }

    private func deleteProject() {
        do {
            modelContext.delete(project)
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting project: \(error.localizedDescription)")
        }
    }

    init(project: ProjectLocal) {
        self.project = project
        _title = State(initialValue: project.title)
        _description = State(initialValue: project.projectDescription ?? "")
        _dueDate = State(initialValue: project.dueDate)
        _budget = State(initialValue: project.budget)
        _status = State(initialValue: project.status)
    }
}

#Preview {
    let project = ProjectLocal(title: "Sample Project", budget: 1000)
    ProjectSettingsView(project: project)
}
