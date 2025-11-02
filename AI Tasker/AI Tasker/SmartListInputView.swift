//
//  SmartListInputView.swift
//  AI Tasker
//
//  Created by Mark Dias on 02/11/2025.
//

import SwiftUI
import CoreData

struct SmartListInputView: View {
    @ObservedObject var field: TaskField
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddItem = false
    @State private var newItemData: [String: String] = [:]

    var listItems: [ListItem] {
        (field.listItems as? Set<ListItem>)?.sorted { $0.itemOrder < $1.itemOrder } ?? []
    }

    var itemFields: [String] {
        guard let jsonStr = field.listItemFields,
              let data = jsonStr.data(using: .utf8),
              let fields = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return fields
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(field.fieldName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(listItems.count) item\(listItems.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // List of items
            if listItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No \(field.fieldName.lowercased()) yet")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: { showingAddItem = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add \(field.fieldName)")
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(listItems, id: \.self) { item in
                        SmartListItemRow(item: item, itemFields: itemFields, viewContext: viewContext)
                    }
                    .onDelete { indexSet in
                        deleteItems(at: indexSet)
                    }

                    Button(action: { showingAddItem = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Another")
                                .font(.caption)
                        }
                    }
                    .padding(.top, 8)
                }
            }

            // Sheet for adding new item
            if showingAddItem {
                SmartListItemEditorSheet(
                    isPresented: $showingAddItem,
                    itemFields: itemFields,
                    onSave: { itemData in
                        addItem(with: itemData)
                    }
                )
            }
        }
        .padding(.vertical, 4)
    }

    private func addItem(with data: [String: String]) {
        let newItem = ListItem(context: viewContext)
        newItem.itemDataValue = data
        newItem.itemOrder = Int16(listItems.count)
        newItem.createdAt = Date()
        newItem.field = field

        do {
            try viewContext.save()
            showingAddItem = false
        } catch {
            print("Error adding list item: \(error)")
        }
    }

    private func deleteItems(at indexSet: IndexSet) {
        withAnimation {
            indexSet.map { listItems[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print("Error deleting list item: \(error)")
            }
        }
    }
}

struct SmartListItemRow: View {
    @ObservedObject var item: ListItem
    let itemFields: [String]
    let viewContext: NSManagedObjectContext
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // Display primary field
                    if let primaryValue = item.itemDataValue[itemFields.first ?? ""] {
                        Text(primaryValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    // Display summary of other fields
                    if itemFields.count > 1 {
                        let otherFields = itemFields.dropFirst()
                        let summary = otherFields
                            .compactMap { field in
                                item.itemDataValue[field].map { "\(field): \($0)" }
                            }
                            .joined(separator: " • ")

                        if !summary.isEmpty {
                            Text(summary)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $isEditing) {
            SmartListItemEditorSheet(
                isPresented: $isEditing,
                itemFields: itemFields,
                initialData: item.itemDataValue,
                onSave: { itemData in
                    item.itemDataValue = itemData
                    try? viewContext.save()
                }
            )
        }
    }
}

struct SmartListItemEditorSheet: View {
    @Binding var isPresented: Bool
    let itemFields: [String]
    var initialData: [String: String] = [:]
    let onSave: ([String: String]) -> Void

    @State private var itemData: [String: String] = [:]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Item Details")) {
                    ForEach(itemFields, id: \.self) { field in
                        TextField(field, text: Binding(
                            get: { itemData[field] ?? "" },
                            set: { itemData[field] = $0 }
                        ))
                    }
                }

                Section {
                    Button(action: {
                        onSave(itemData)
                        isPresented = false
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)

                    Button("Cancel", role: .cancel) {
                        isPresented = false
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                itemData = initialData
            }
        }
    }
}

#Preview {
    Text("SmartListInputView Preview")
}
