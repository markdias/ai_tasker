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
    @State private var textValue = ""
    @State private var numberValue = ""
    @State private var dateValue = Date()
    @State private var toggleValue = false
    @State private var listItems: [String] = []

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
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(listItems.enumerated()), id: \.offset) { index, item in
                        HStack {
                            TextField("Item \(index + 1)", text: Binding(
                                get: { item },
                                set: {
                                    var items = listItems
                                    items[index] = $0
                                    listItems = items
                                    updateListValue()
                                }
                            ))
                            .textFieldStyle(.roundedBorder)

                            Button(action: {
                                listItems.remove(at: index)
                                updateListValue()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Button(action: {
                        listItems.append("")
                        updateListValue()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Item")
                        }
                        .font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            loadFieldValue()
        }
    }

    private func loadFieldValue() {
        switch field.fieldTypeValue {
        case .text:
            textValue = field.fieldValue ?? ""
        case .number:
            numberValue = field.fieldValue ?? ""
        case .date:
            // Date is handled in binding
            break
        case .toggle:
            toggleValue = field.fieldValue == "true"
        case .list:
            if let jsonStr = field.fieldValue,
               let data = jsonStr.data(using: .utf8),
               let items = try? JSONDecoder().decode([String].self, from: data) {
                listItems = items
            }
        }
    }

    private func saveField() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving field: \(error)")
        }
    }

    private func updateListValue() {
        if let data = try? JSONEncoder().encode(listItems),
           let jsonStr = String(data: data, encoding: .utf8) {
            field.fieldValue = jsonStr
            saveField()
        }
    }
}

#Preview {
    Text("TaskFieldsInputView Preview")
}
