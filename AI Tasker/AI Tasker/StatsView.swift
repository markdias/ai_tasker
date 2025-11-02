//
//  StatsView.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import SwiftUI
import CoreData

struct StatsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)],
        animation: .default)
    private var allTasks: FetchedResults<Task>

    var completedTasks: [Task] {
        allTasks.filter { $0.isCompletedFlag }
    }

    var completedToday: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return completedTasks.filter { task in
            let createdAt = task.updatedAt ?? task.createdAtValue
            return calendar.startOfDay(for: createdAt) == today
        }.count
    }

    var completionPercentage: Double {
        guard allTasks.count > 0 else { return 0 }
        return Double(completedTasks.count) / Double(allTasks.count) * 100
    }

    var totalTimeSpent: Int {
        completedTasks.reduce(0) { $0 + Int($1.estimatedTime) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Today's Progress")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Completed Today")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(completedToday)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("Overall Completion")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f%%", completionPercentage))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }

                    ProgressView(value: completionPercentage, total: 100)
                        .tint(.blue)
                }

                Section(header: Text("Time Spent")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(totalTimeSpent)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("Hours")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f", Double(totalTimeSpent) / 60))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                }

                Section(header: Text("Summary")) {
                    HStack {
                        Label("Total Tasks", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(allTasks.count)")
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(completedTasks.count)")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }

                    HStack {
                        Label("Remaining", systemImage: "circle")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(allTasks.count - completedTasks.count)")
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    StatsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
