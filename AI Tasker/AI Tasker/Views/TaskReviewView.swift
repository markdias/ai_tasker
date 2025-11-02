import SwiftUI
import SwiftData

struct TaskReviewView: View {
    @State private var appState: AppState
    @State private var projectTitle: String = ""
    @Environment(\.modelContext) private var modelContext

    var acceptedTaskCount: Int {
        appState.generatedTasks.filter { $0.isAccepted }.count
    }

    var canSave: Bool {
        !projectTitle.trimmingCharacters(in: .whitespaces).isEmpty && acceptedTaskCount > 0
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Review Your Tasks")
                    .font(.system(size: 24, weight: .bold))
                Text("\(acceptedTaskCount) task\(acceptedTaskCount == 1 ? "" : "s") selected")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Project Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Project Name")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)

                TextField("e.g., Birthday Party Planning", text: $projectTitle)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 16)

            // Tasks List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(appState.generatedTasks.enumerated()), id: \.element.id) { index, task in
                        TaskReviewCard(
                            task: task,
                            isAccepted: $appState.generatedTasks[index].isAccepted,
                            onToggle: {
                                appState.toggleTaskAcceptance(index)
                            }
                        )
                    }
                }
                .padding(16)
            }

            Spacer()

            // Action Buttons
            VStack(spacing: 12) {
                Button(action: saveProject) {
                    Text("Save \(acceptedTaskCount) Task\(acceptedTaskCount == 1 ? "" : "s")")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(canSave ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!canSave)

                Button(action: goBack) {
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Actions

    private func saveProject() {
        appState.saveProject(title: projectTitle, modelContext: modelContext)
    }

    private func goBack() {
        appState.navigateTo(.questionForm)
    }

    init(appState: AppState) {
        _appState = State(initialValue: appState)
    }
}

// MARK: - Task Review Card

struct TaskReviewCard: View {
    let task: GeneratedTaskModel
    @Binding var isAccepted: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                    Text(task.description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 10))
                        Text(task.type.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                }

                Spacer()

                Button(action: onToggle) {
                    Image(systemName: isAccepted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isAccepted ? .blue : .gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(isAccepted ? 1.0 : 0.6)
    }
}

#Preview {
    let appState = AppState()
    appState.generatedTasks = [
        GeneratedTaskModel(
            title: "Create Guest List",
            description: "Compile the list of guests",
            type: "list",
            inputFields: []
        ),
    ]
    return TaskReviewView(appState: appState)
        .modelContainer(for: ProjectLocal.self, inMemory: true)
}
