import SwiftUI
import Speech

struct HomeView: View {
    @State private var appState: AppState
    @State private var promptText: String = ""
    @State private var isRecording: Bool = false
    @State private var recordingError: String?
    @State private var useAI: Bool = true // Toggle between mock and real AI

    let speechRecognizer = SpeechRecognizer.shared

    var isInputValid: Bool {
        !promptText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header with Settings Button
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Promptodo")
                            .font(.system(size: 32, weight: .bold))
                        Text("Turn ideas into actionable tasks")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    NavigationLink(destination: APISettingsView()) {
                        Image(systemName: "gear")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)

            Spacer()

            // Prompt Input Section
            VStack(spacing: 16) {
                Text("What would you like to create?")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Text Input
                TextEditor(text: $promptText)
                    .frame(height: 120)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .font(.system(size: 16))

                // Voice Recording Button
                HStack(spacing: 12) {
                    Button(action: toggleRecording) {
                        HStack(spacing: 8) {
                            Image(systemName: isRecording ? "mic.fill" : "mic")
                            Text(isRecording ? "Recording..." : "Use Voice")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(!speechRecognizer.isAvailable)

                    Button(action: clearPrompt) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                }

                if let error = recordingError {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)

            Spacer()

            // AI Mode Toggle
            Toggle("Use ChatGPT AI", isOn: $useAI)
                .padding(.horizontal, 16)
                .font(.system(size: 14, weight: .semibold))

            // Generate Questions Button
            Button(action: generateQuestions) {
                HStack(spacing: 8) {
                    if appState.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(appState.isLoading ? "Generating..." : "Generate Questions")
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(isInputValid && !appState.isLoading ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!isInputValid || appState.isLoading)

            Text("No account needed • All data saved locally")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.bottom, 16)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: - Actions

    private func generateQuestions() {
        appState.setPrompt(promptText)
        if useAI {
            appState.generateQuestionsWithAI()
        } else {
            appState.generateMockQuestions()
        }
    }

    private func toggleRecording() {
        if isRecording {
            speechRecognizer.stopRecording()
            isRecording = false
        } else {
            isRecording = true
            recordingError = nil

            speechRecognizer.startRecording { [self] text, error in
                DispatchQueue.main.async { [self] in
                    self.isRecording = false

                    if let text = text {
                        self.promptText.append(" \(text)")
                    } else if let error = error {
                        self.recordingError = error.localizedDescription
                    }
                }
            }
        }
    }

    private func clearPrompt() {
        promptText = ""
        recordingError = nil
    }

    init(appState: AppState) {
        _appState = State(initialValue: appState)
    }
}

#Preview {
    HomeView(appState: AppState())
}
