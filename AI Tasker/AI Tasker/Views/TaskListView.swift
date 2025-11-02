import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) var modelContext
    let project: ProjectLocal

    @State private var filterStatus: String = "all" // "all", "pending", "in_progress", "completed"
    @State private var sortBy: String = "created" // "created", "dueDate", "cost"
    @State private var showProjectSettings: Bool = false

    var filteredAndSortedTasks: [TaskLocal] {
        let filtered = project.tasks.filter { task in
            if filterStatus == "all" {
                return true
            }
            return task.status == filterStatus
        }

        return filtered.sorted { task1, task2 in
            switch sortBy {
            case "dueDate":
                let date1 = task1.dueDate ?? Date(timeIntervalSince1970: 0)
                let date2 = task2.dueDate ?? Date(timeIntervalSince1970: 0)
                return date1 < date2
            case "cost":
                return task1.cost > task2.cost
            default: // "created"
                return task1.createdAt < task2.createdAt
            }
        }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with gradient background
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(project.title)
                            .font(.system(size: 26, weight: .bold))
                        if let description = project.projectDescription {
                            Text(description)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    NavigationLink(destination: ProjectSettingsView(project: project)) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
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

                // Filter & Sort Controls
                VStack(spacing: 12) {
                    // Status Filter
                    HStack(spacing: 8) {
                        Text("Filter:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)

                        Picker("Status", selection: $filterStatus) {
                            Text("All").tag("all")
                            Text("Pending").tag("pending")
                            Text("In Progress").tag("in_progress")
                            Text("Completed").tag("completed")
                        }
                        .pickerStyle(.segmented)
                        .font(.system(size: 11))
                    }

                    // Sort Options
                    HStack(spacing: 8) {
                        Text("Sort:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)

                        Menu {
                            Button(action: { sortBy = "created" }) {
                                HStack {
                                    if sortBy == "created" {
                                        Image(systemName: "checkmark")
                                    }
                                    Text("Date Created")
                                }
                            }
                            Button(action: { sortBy = "dueDate" }) {
                                HStack {
                                    if sortBy == "dueDate" {
                                        Image(systemName: "checkmark")
                                    }
                                    Text("Due Date")
                                }
                            }
                            Button(action: { sortBy = "cost" }) {
                                HStack {
                                    if sortBy == "cost" {
                                        Image(systemName: "checkmark")
                                    }
                                    Text("Cost")
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 12, weight: .semibold))
                                Text(sortLabel)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }

                        Spacer()
                    }
                }
                .padding(16)

                if filteredAndSortedTasks.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundColor(.gray.opacity(0.4))
                        VStack(spacing: 8) {
                            Text(filterStatus == "all" ? "No Tasks" : "No \(filterStatus) Tasks")
                                .font(.system(size: 18, weight: .semibold))
                            Text("All tasks completed or no tasks yet")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                } else {
                    // Tasks List
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(filteredAndSortedTasks) { task in
                                NavigationLink(destination: TaskDetailsView(task: task)) {
                                    TaskRowViewEnhanced(task: task)
                                }
                            }
                        }
                        .padding(16)
                    }
                }

                Spacer()

                // Stats Footer with Budget
                VStack(spacing: 14) {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tasks")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            HStack(spacing: 4) {
                                Text("\(project.completedTaskCount)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.green)
                                Text("/ \(project.taskCount)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }

                        Divider()
                            .frame(height: 40)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Progress")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                        }

                        Spacer()
                    }

                    // Budget Bar (if budget is set)
                    if project.budget > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Budget")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.gray)
                                    Text(String(format: "$%.2f / $%.2f", project.totalTaskCost, project.budget))
                                        .font(.system(size: 13, weight: .semibold))
                                }

                                Spacer()

                                Text(String(format: "%.0f%%", project.budgetPercentageUsed * 100))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(project.remainingBudget >= 0 ? .green : .red)
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.systemGray4).opacity(0.5))

                                    Capsule()
                                        .fill(project.remainingBudget >= 0 ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.green,
                                                    Color.green.opacity(0.8)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ) :
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.red,
                                                    Color.red.opacity(0.8)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * min(project.budgetPercentageUsed, 1.0))
                                }
                                .frame(height: 8)
                            }
                            .frame(height: 8)
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(14)
                .padding(16)
            }
        }
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.inline)
    }

    var progressPercentage: Double {
        project.taskCount > 0 ? Double(project.completedTaskCount) / Double(project.taskCount) : 0
    }

    var sortLabel: String {
        switch sortBy {
        case "dueDate":
            return "Due Date"
        case "cost":
            return "Cost"
        default:
            return "Created"
        }
    }
}

// MARK: - Enhanced Task Row View (with quick actions)

struct TaskRowViewEnhanced: View {
    let task: TaskLocal
    @Environment(\.modelContext) var modelContext

    var statusIcon: String {
        switch task.status {
        case "completed":
            return "checkmark.circle.fill"
        case "in_progress":
            return "progress.indicator"
        default:
            return "circle"
        }
    }

    var statusColor: Color {
        switch task.status {
        case "completed":
            return .green
        case "in_progress":
            return .orange
        default:
            return .gray
        }
    }

    var nextStatus: String {
        switch task.status {
        case "pending":
            return "in_progress"
        case "in_progress":
            return "completed"
        default:
            return "pending"
        }
    }

    var nextStatusIcon: String {
        switch nextStatus {
        case "completed":
            return "checkmark.circle.fill"
        case "in_progress":
            return "progress.indicator"
        default:
            return "circle"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Status Icon (clickable for quick status change)
                Button(action: toggleStatus) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(statusColor)
                        .frame(width: 32, height: 32)
                        .background(statusColor.opacity(0.1))
                        .cornerRadius(8)
                }

                // Task Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if let description = task.taskDescription {
                        Text(description)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Type Badge
                HStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 10))
                    Text(task.type.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }

            // Additional Details
            HStack(spacing: 8) {
                if let dueDate = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.blue)
                        Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 11, weight: .regular))
                    }
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(4)
                }

                if task.cost > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.green)
                        Text(String(format: "$%.2f", task.cost))
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.05))
                    .cornerRadius(4)
                }

                if let category = task.category {
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 10))
                        Text(category)
                            .font(.system(size: 11, weight: .regular))
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(4)
                }

                Spacer()

                // Quick Action: Mark as next status
                Button(action: toggleStatus) {
                    Image(systemName: nextStatusIcon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
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
                        .cornerRadius(6)
                }
            }
        }
        .padding(14)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.08), lineWidth: 1)
        )
    }

    private func toggleStatus() {
        task.status = nextStatus
        task.updatedAt = Date()

        do {
            try modelContext.save()
        } catch {
            print("Error updating task status: \(error.localizedDescription)")
        }
    }
}

// MARK: - Original Task Row View (for reference)

struct TaskRowView: View {
    let task: TaskLocal
    @Environment(\.modelContext) var modelContext

    var statusIcon: String {
        switch task.status {
        case "completed":
            return "checkmark.circle.fill"
        case "in_progress":
            return "progress.indicator"
        default:
            return "circle"
        }
    }

    var statusColor: Color {
        switch task.status {
        case "completed":
            return .green
        case "in_progress":
            return .orange
        default:
            return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Status Icon
                Image(systemName: statusIcon)
                    .font(.system(size: 16))
                    .foregroundColor(statusColor)

                // Task Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    if let description = task.taskDescription {
                        Text(description)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Type Badge
                HStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 10))
                    Text(task.type.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
            }

            // Additional Details
            HStack(spacing: 12) {
                if let dueDate = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 11, weight: .regular))
                    }
                    .foregroundColor(.gray)
                }

                if task.cost > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 11))
                        Text(String(format: "$%.2f", task.cost))
                            .font(.system(size: 11, weight: .regular))
                    }
                    .foregroundColor(.green)
                }

                Spacer()
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let project = ProjectLocal(title: "Sample Project")
    TaskListView(project: project)
}
