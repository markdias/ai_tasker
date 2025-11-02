//
//  TaskFieldsInputView.swift
//  AI Tasker
//
//  Created by Mark Dias on 02/11/2025.
//

import SwiftUI
import CoreData

struct TaskFieldsInputView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showAlert = false
    @State private var alertMessage = ""

    var fieldsArray: [TaskField] {
        (task.fields as? Set<TaskField>)?.sorted { $0.fieldOrder < $1.fieldOrder } ?? []
    }

    var body: some View {
        if fieldsArray.isEmpty {
            Text("No additional details needed")
                .foregroundColor(.secondary)
                .font(.caption)
        } else {
            VStack(spacing: 16) {
                ForEach(fieldsArray, id: \.self) { field in
                    TaskFieldInputRow(field: field, viewContext: viewContext)
                }
            }
        }
    }
}

struct TaskFieldInputRow: View {
    @ObservedObject var field: TaskField
    let viewContext: NSManagedObjectContext

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(field.fieldName)
                .font(.subheadline)
                .fontWeight(.semibold)

            switch field.fieldTypeValue {
            case .text:
                TextField("Enter \(field.fieldName.lowercased())", text: Binding(
                    get: { field.fieldValue ?? "" },
                    set: { field.fieldValue = $0; saveField() }
                ))
                .textFieldStyle(.roundedBorder)

            case .number:
                TextField("Enter number", text: Binding(
                    get: { field.fieldValue ?? "" },
                    set: { field.fieldValue = $0; saveField() }
                ))
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)

            case .date:
                DatePicker(
                    "Select date",
                    selection: Binding(
                        get: {
                            if let dateStr = field.fieldValue,
                               let date = ISO8601DateFormatter().date(from: dateStr) {
                                return date
                            }
                            return Date()
                        },
                        set: { date in
                            field.fieldValue = ISO8601DateFormatter().string(from: date)
                            saveField()
                        }
                    ),
                    displayedComponents: [.date]
                )

            case .toggle:
                Toggle("", isOn: Binding(
                    get: { field.fieldValue == "true" },
                    set: { value in
                        field.fieldValue = value ? "true" : "false"
                        saveField()
                    }
                ))

            case .list:
                SmartListInputView(field: field)
            }
        }
        .padding(.vertical, 4)
    }

    private func saveField() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving field: \(error)")
        }
    }
}

#Preview {
    Text("TaskFieldsInputView Preview")
}
