//
//  TaskDetailView.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import SwiftUI
import CoreData

struct TaskDetailView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @State private var editTitle = ""
    @State private var editDescription = ""
    @State private var editEstimatedTime: Int16 = 0
    @State private var editPriority = "medium"
    @State private var editCategory = ""
    @State private var editScheduledTime: Date?
    @State private var showTimeSelector = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    let priorities = ["low", "medium", "high"]
    let categories = ["work", "study", "personal", "health", "home"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $editTitle)

                    TextEditor(text: $editDescription)
                        .frame(height: 80)
                        .placeholder(when: editDescription.isEmpty) {
                            Text("Add a description (optional)")
                                .foregroundColor(.gray)
                        }
                }

                Section(header: Text("Properties")) {
                    Picker("Priority", selection: $editPriority) {
                        ForEach(priorities, id: \.self) { priority in
                            Text(priority.capitalized).tag(priority)
                        }
                    }

                    Picker("Category", selection: $editCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.capitalized).tag(category)
                        }
                    }

                    Stepper(
                        "Estimated Time: \(editEstimatedTime) min",
                        value: $editEstimatedTime,
                        in: 5...480,
                        step: 5
                    )
                }

                Section(header: Text("Scheduling")) {
                    Toggle("Schedule Task", isOn: Binding(
                        get: { editScheduledTime != nil },
                        set: { isOn in
                            if isOn {
                                editScheduledTime = Date()
                            } else {
                                editScheduledTime = nil
                            }
                        }
                    ))

                    if editScheduledTime != nil {
                        DatePicker(
                            "Scheduled Time",
                            selection: Binding(
                                get: { editScheduledTime ?? Date() },
                                set: { editScheduledTime = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

                Section(header: Text("Task Details")) {
                    TaskFieldsInputView(task: task)
                }

                Section {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)

                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                editTitle = task.title
                editDescription = task.taskDescription ?? ""
                editEstimatedTime = task.estimatedTime
                editPriority = task.priority ?? "medium"
                editCategory = task.category ?? ""
                editScheduledTime = task.scheduledTime
            }
            .alert("Success", isPresented: $showAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func saveChanges() {
        withAnimation {
            task.title = editTitle.isEmpty ? "Untitled" : editTitle
            task.taskDescription = editDescription.isEmpty ? nil : editDescription
            task.estimatedTime = editEstimatedTime
            task.priority = editPriority
            task.category = editCategory
            task.scheduledTime = editScheduledTime
            task.updatedAtValue = Date()

            do {
                try viewContext.save()

                // Handle notification scheduling
                if editScheduledTime != nil {
                    NotificationManager.shared.scheduleTaskReminder(task: task)
                } else {
                    // Cancel reminder if scheduled time was removed
                    let taskId = task.objectID.uriRepresentation().lastPathComponent
                    NotificationManager.shared.cancelTaskReminder(taskId: taskId)
                }

                alertMessage = "Task updated successfully"
                showAlert = true
            } catch {
                let nsError = error as NSError
                alertMessage = "Error saving task: \(nsError.localizedDescription)"
                showAlert = true
            }
        }
    }
}

#Preview {
    TaskDetailView(task: Task(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
