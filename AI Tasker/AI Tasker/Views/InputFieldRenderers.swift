import SwiftUI
import Foundation

// MARK: - Data Structures

struct ListItem: Identifiable, Equatable {
    let id: UUID
    var text: String
    var completed: Bool
}

/// Universal input field renderer that handles all task input types
struct DynamicInputRenderer: View {
    let field: InputFieldDefinition
    @Binding var value: String
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Field Label
            HStack {
                Text(field.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)

                if field.required {
                    Text("*")
                        .foregroundColor(.red)
                }

                Spacer()
            }

            // Input based on type
            switch field.type {
            case "text":
                TextInputField(value: $value)

            case "number":
                NumberInputField(value: $value)

            case "currency":
                CurrencyInputField(value: $value)

            case "date":
                DateInputField(value: $value)

            case "checkbox":
                CheckboxInputField(value: $value)

            case "list":
                ListInputField(value: $value)

            default:
                TextInputField(value: $value)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Text Input

struct TextInputField: View {
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Enter text", text: $value)
                .padding(10)
                .background(Color(.systemBackground))
                .cornerRadius(6)
                .font(.system(size: 14))

            if !value.isEmpty {
                HStack {
                    Spacer()
                    Text("\(value.count) characters")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Number Input

struct NumberInputField: View {
    @Binding var value: String
    @State private var numValue: Double = 0

    var body: some View {
        HStack(spacing: 12) {
            TextField("0", value: $numValue, format: .number)
                .keyboardType(.decimalPad)
                .padding(10)
                .background(Color(.systemBackground))
                .cornerRadius(6)
                .font(.system(size: 14))
                .onChange(of: numValue) { newValue in
                    value = String(newValue)
                }

            Button(action: decreaseValue) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }

            Button(action: increaseValue) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
        }
    }

    private func increaseValue() {
        numValue += 1
    }

    private func decreaseValue() {
        if numValue > 0 {
            numValue -= 1
        }
    }
}

// MARK: - Currency Input

struct CurrencyInputField: View {
    @Binding var value: String
    @State private var currencyValue: Double = 0
    let currencyFormatter = NumberFormatter()

    init(value: Binding<String>) {
        _value = value
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
    }

    var displayValue: String {
        if currencyValue == 0 {
            return "$0.00"
        }
        return currencyFormatter.string(from: NSNumber(value: currencyValue)) ?? "$0.00"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text("$")
                    .font(.system(size: 16, weight: .semibold))

                TextField("0.00", value: $currencyValue, format: .number)
                    .keyboardType(.decimalPad)
                    .padding(10)
                    .background(Color(.systemBackground))
                    .cornerRadius(6)
                    .font(.system(size: 14))
                    .onChange(of: currencyValue) { newValue in
                        value = String(format: "%.2f", newValue)
                    }
            }

            // Quick amount buttons
            HStack(spacing: 8) {
                ForEach([10, 25, 50, 100], id: \.self) { amount in
                    Button(action: { currencyValue = Double(amount) }) {
                        Text("$\(amount)")
                            .font(.system(size: 12, weight: .semibold))
                            .padding(6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }

            Text("Total: \(displayValue)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.green)
        }
    }
}

// MARK: - Date Input

struct DateInputField: View {
    @Binding var value: String
    @State private var selectedDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker(
                "Select date",
                selection: $selectedDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .onChange(of: selectedDate) { newDate in
                value = ISO8601DateFormatter().string(from: newDate)
            }

            Text(selectedDate.formatted(date: .complete, time: .shortened))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Checkbox Input

struct CheckboxInputField: View {
    @Binding var value: String

    var isChecked: Bool {
        value.lowercased() == "true"
    }

    var body: some View {
        Button(action: toggleCheckbox) {
            HStack(spacing: 12) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(isChecked ? .green : .gray)

                Text(isChecked ? "Checked" : "Not checked")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(6)
        }
    }

    private func toggleCheckbox() {
        value = isChecked ? "false" : "true"
    }
}

// MARK: - List Input

struct ListInputField: View {
    @Binding var value: String
    @State private var listItems: [ListItem] = []
    @State private var newItem: String = ""
    @State private var editingId: UUID? = nil
    @State private var editingText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var completedCount: Int {
        listItems.filter { $0.completed }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Input Section
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)

                    TextField("Add a new item...", text: $newItem)
                        .font(.system(size: 15, weight: .regular))
                        .focused($isTextFieldFocused)
                        .submitLabel(.return)
                        .onSubmit(addItem)

                    if !newItem.isEmpty {
                        Button(action: addItem) {
                            Text("Add")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }

            // Items List
            if listItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 32))
                        .foregroundColor(.gray.opacity(0.5))

                    VStack(spacing: 4) {
                        Text("No items yet")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("Add your first item to get started")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(listItems.enumerated()), id: \.element.id) { index, item in
                        if editingId == item.id {
                            // Editing mode
                            HStack(spacing: 12) {
                                Image(systemName: "pencil.line")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)

                                TextField("Edit item", text: $editingText)
                                    .font(.system(size: 14, weight: .regular))
                                    .submitLabel(.return)
                                    .onSubmit { saveEdit(at: index) }

                                HStack(spacing: 8) {
                                    Button(action: { saveEdit(at: index) }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.green)
                                    }
                                    .disabled(editingText.trimmingCharacters(in: .whitespaces).isEmpty)

                                    Button(action: { editingId = nil; editingText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color.blue.opacity(0.08))
                            .cornerRadius(10)
                        } else {
                            // Normal display mode
                            HStack(spacing: 12) {
                                // Completion checkbox
                                Button(action: { toggleCompletion(at: index) }) {
                                    Image(systemName: item.completed ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(item.completed ? .green : .gray.opacity(0.5))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.text)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(item.completed ? .gray : .primary)
                                        .strikethrough(item.completed, color: .gray)
                                        .lineLimit(2)
                                }

                                Spacer()

                                HStack(spacing: 4) {
                                    Button(action: { startEdit(at: index, item: item) }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.blue)
                                            .padding(6)
                                    }

                                    Button(action: { removeItem(at: index) }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.red)
                                            .padding(6)
                                    }
                                }
                                .padding(.trailing, -6)
                            }
                            .padding(12)
                            .background(Color(.systemGray6).opacity(0.6))
                            .cornerRadius(10)
                        }
                    }
                }
            }

            // Progress Footer
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(listItems.count) item\(listItems.count == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)

                    if completedCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                            Text("\(completedCount) completed")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.green)
                        }
                    }
                }

                Spacer()

                if listItems.count > 0 {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)

                        Capsule()
                            .fill(Color.green)
                            .frame(width: 60 * Double(completedCount) / Double(listItems.count), height: 6)
                    }
                    .frame(width: 60)
                }
            }
            .padding(10)
            .background(Color(.systemGray6).opacity(0.3))
            .cornerRadius(8)
        }
        .onAppear {
            loadListItems()
        }
        .onChange(of: listItems) {
            saveListItems()
        }
    }

    private func addItem() {
        let trimmed = newItem.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        listItems.append(ListItem(id: UUID(), text: trimmed, completed: false))
        newItem = ""
    }

    private func removeItem(at index: Int) {
        listItems.remove(at: index)
    }

    private func startEdit(at index: Int, item: ListItem) {
        editingId = item.id
        editingText = item.text
    }

    private func saveEdit(at index: Int) {
        let trimmed = editingText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        listItems[index].text = trimmed
        editingId = nil
        editingText = ""
    }

    private func toggleCompletion(at index: Int) {
        listItems[index].completed.toggle()
    }

    private func loadListItems() {
        if let data = value.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            listItems = decoded.map { ListItem(id: UUID(), text: $0, completed: false) }
        }
    }

    private func saveListItems() {
        let itemsToSave = listItems.map { $0.text }
        if let encoded = try? JSONEncoder().encode(itemsToSave),
           let jsonString = String(data: encoded, encoding: .utf8) {
            value = jsonString
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        DynamicInputRenderer(
            field: InputFieldDefinition(name: "text_field", label: "Task Name", type: "text", required: true),
            value: .constant("Sample text")
        )

        DynamicInputRenderer(
            field: InputFieldDefinition(name: "budget", label: "Budget", type: "currency", required: true),
            value: .constant("100.00")
        )

        DynamicInputRenderer(
            field: InputFieldDefinition(name: "due_date", label: "Due Date", type: "date", required: false),
            value: .constant("")
        )
    }
    .padding(16)
}
