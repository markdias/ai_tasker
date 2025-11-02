import SwiftUI
import Foundation

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
    @State private var listItems: [String] = []
    @State private var newItem: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Add new item
            HStack(spacing: 8) {
                TextField("Add item", text: $newItem)
                    .padding(10)
                    .background(Color(.systemBackground))
                    .cornerRadius(6)
                    .font(.system(size: 14))

                Button(action: addItem) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // List items
            if listItems.isEmpty {
                Text("No items yet")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(10)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(listItems.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 12) {
                            Text(String(format: "%d.", index + 1))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                                .frame(width: 20)

                            Text(item)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.primary)

                            Spacer()

                            Button(action: { removeItem(at: index) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(10)
                        .background(Color(.systemBackground))
                        .cornerRadius(6)
                    }
                }
            }

            // Item counter
            Text("\(listItems.count) item\(listItems.count == 1 ? "" : "s")")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.gray)
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

        listItems.append(trimmed)
        newItem = ""
    }

    private func removeItem(at index: Int) {
        listItems.remove(at: index)
    }

    private func loadListItems() {
        if let data = value.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            listItems = decoded
        }
    }

    private func saveListItems() {
        if let encoded = try? JSONEncoder().encode(listItems),
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
