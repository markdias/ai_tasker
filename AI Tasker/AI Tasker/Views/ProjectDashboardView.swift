import SwiftUI
import SwiftData

struct ProjectDashboardView: View {
    @State private var appState: AppState
    @Query private var projects: [ProjectLocal]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Projects")
                        .font(.system(size: 28, weight: .bold))
                    Text("\(projects.count) project\(projects.count == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)

                if projects.isEmpty {
                    EmptyStateView(appState: appState)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(projects) { project in
                                ProjectCard(project: project)
                            }
                        }
                        .padding(16)
                    }
                }

                Spacer()

                // New Project Button
                Button(action: createNewProject) {
                    Text("Create New Project")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(16)
            }
            .background(Color(.systemBackground))
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
        project.taskCount > 0 ? Double(project.completedTaskCount) / Double(project.taskCount) : 0
    }

    var body: some View {
        NavigationLink(destination: TaskListView(project: project)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(project.title)
                            .font(.system(size: 16, weight: .semibold))
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
                        Text("\(project.completedTaskCount)/\(project.taskCount)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("tasks")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray4))

                        Capsule()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * progressPercentage)
                    }
                    .frame(height: 6)
                }
                .frame(height: 6)

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(project.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "inbox.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text("No Projects Yet")
                    .font(.system(size: 18, weight: .semibold))
                Text("Create your first project by answering a few questions")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button(action: createNewProject) {
                Text("Create First Project")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.blue)
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
