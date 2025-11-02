import SwiftUI

struct QuestionFormView: View {
    @State private var appState: AppState
    @State private var currentQuestionIndex: Int = 0
    @State private var useAI: Bool = true // Match Home toggle

    var totalQuestions: Int {
        appState.currentQuestions.count
    }

    var isAnswered: Bool {
        !appState.currentAnswers[currentQuestionIndex].trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canGoNext: Bool {
        isAnswered || currentQuestionIndex == totalQuestions - 1
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Answer a few questions")
                    .font(.system(size: 24, weight: .bold))

                // Progress indicator
                HStack(spacing: 4) {
                    ForEach(0..<totalQuestions, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentQuestionIndex ? Color.blue : Color(.systemGray4))
                            .frame(height: 4)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)

            Spacer()

            // Question Card
            if currentQuestionIndex < appState.currentQuestions.count {
                let question = appState.currentQuestions[currentQuestionIndex]
                VStack(alignment: .leading, spacing: 20) {
                    Text("Question \(question.index) of \(totalQuestions)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)

                    Text(question.text)
                        .font(.system(size: 20, weight: .semibold))

                    // Answer TextField
                    TextEditor(text: $appState.currentAnswers[currentQuestionIndex])
                        .frame(height: 120)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .font(.system(size: 16))

                    Spacer()
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }

            Spacer()

            // Navigation Buttons
            HStack(spacing: 12) {
                // Previous Button
                Button(action: previousQuestion) {
                    Text("Previous")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(currentQuestionIndex > 0 ? Color(.systemGray4) : Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                .disabled(currentQuestionIndex == 0 || appState.isLoading)

                // Next/Submit Button
                Button(action: nextQuestion) {
                    HStack(spacing: 8) {
                        if appState.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(appState.isLoading ? "Generating..." : (currentQuestionIndex == totalQuestions - 1 ? "Generate Tasks" : "Next"))
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(canGoNext && !appState.isLoading ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(!canGoNext || appState.isLoading)
            }
            .padding(.bottom, 16)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Actions

    private func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }

    private func nextQuestion() {
        if currentQuestionIndex < totalQuestions - 1 {
            currentQuestionIndex += 1
        } else {
            // Generate tasks (AI or mock)
            if useAI {
                appState.generateTasksWithAI()
            } else {
                appState.generateMockTasks()
            }
        }
    }

    init(appState: AppState) {
        _appState = State(initialValue: appState)
    }
}

#Preview {
    let appState = AppState()
    appState.currentQuestions = [
        QuestionCard(index: 1, text: "What's the occasion?"),
        QuestionCard(index: 2, text: "How many people?"),
    ]
    return QuestionFormView(appState: appState)
}
