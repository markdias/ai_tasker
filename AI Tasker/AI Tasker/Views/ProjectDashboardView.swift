import SwiftUI
import SwiftData

struct ProjectDashboardView: View {
    @State private var appState: AppState
    @Query private var projects: [ProjectLocal]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with gradient background
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Projects")
                            .font(.system(size: 28, weight: .bold))
                        Text("\(projects.count) project\(projects.count == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
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

                    if projects.isEmpty {
                        EmptyStateView(appState: appState)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(projects) { project in
                                    ProjectCard(project: project)
                                }
                            }
                            .padding(16)
                        }
                    }

                    Spacer()

                    // New Project Button
                    VStack(spacing: 12) {
                        Button(action: createNewProject) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create New Project")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(14)
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
                            .cornerRadius(12)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    private func createNewProject() {
        appState.resetFlow()
    }

    init(appState: AppState) {
        _appState = State(initialValue: appState)
    }
}

// MARK: - Project Card

struct ProjectCard: View {
    let project: ProjectLocal

    var progressPercentage: Double {
        project.computedProgress
    }

    var budgetPercentageUsed: Double {
        project.budget > 0 ? min(project.totalTaskCost / project.budget, 1.0) : 0
    }

    var body: some View {
        NavigationLink(destination: TaskListView(project: project)) {
            VStack(alignment: .leading, spacing: 14) {
                // Title Section
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(project.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        if let projectDescription = project.projectDescription {
                            Text(projectDescription)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            Text("\(project.computedCompletedTaskCount)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        Text("of \(project.computedTaskCount)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }

                // Task Progress Section
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.0f%%", progressPercentage * 100))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray4).opacity(0.5))

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue,
                                            Color.blue.opacity(0.8)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progressPercentage)
                        }
                        .frame(height: 8)
                    }
                    .frame(height: 8)
                }

                // Budget Display (if budget is set)
                if project.budget > 0 {
                    Divider()
                        .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Budget")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            Spacer()
                            HStack(spacing: 2) {
                                Text(String(format: "$%.2f", project.totalTaskCost))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(String(format: "/ $%.2f", project.budget))
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                        }

                        // Budget Usage Bar
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
                                    .frame(width: geometry.size.width * budgetPercentageUsed)
                            }
                            .frame(height: 6)
                        }
                        .frame(height: 6)
                    }
                }

                // Footer with Date
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)
                    Text(project.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .padding(14)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.blue.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "inbox.fill")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundColor(.blue.opacity(0.6))

                VStack(spacing: 12) {
                    Text("No Projects Yet")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Create your first project by answering a few questions about what you want to organize")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(24)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(16)

            Spacer()

            Button(action: createNewProject) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Create First Project")
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(14)
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
                .cornerRadius(12)
            }
            .padding(16)

            Spacer()
        }
    }

    private func createNewProject() {
        appState.resetFlow()
    }
}

#Preview {
    ProjectDashboardView(appState: AppState())
        .modelContainer(for: ProjectLocal.self, inMemory: true)
}
