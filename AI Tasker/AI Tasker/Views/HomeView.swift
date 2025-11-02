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
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with gradient background
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Promptodo")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Turn ideas into actionable tasks")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.blue)
                                .padding(10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
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

                    ScrollView {
                        VStack(spacing: 20) {
                            // Prompt Input Section with modern styling
                            VStack(spacing: 14) {
                                Text("What would you like to create?")
                                    .font(.system(size: 17, weight: .semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.primary)

                                // Text Input
                                TextEditor(text: $promptText)
                                    .frame(height: 110)
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .border(Color.blue.opacity(0.2), width: 1)
                                    .font(.system(size: 16))

                                // Voice Recording and Clear Buttons
                                HStack(spacing: 10) {
                                    Button(action: toggleRecording) {
                                        HStack(spacing: 8) {
                                            Image(systemName: isRecording ? "mic.fill" : "mic")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text(isRecording ? "Recording..." : "Use Voice")
                                                .font(.system(size: 15, weight: .semibold))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .background(
                                            isRecording ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.red,
                                                    Color.red.opacity(0.8)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
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
                                        .cornerRadius(10)
                                    }
                                    .disabled(!speechRecognizer.isAvailable)

                                    Button(action: clearPrompt) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.gray.opacity(0.6))
                                            .frame(width: 44, height: 44)
                                            .background(Color(.systemGray6).opacity(0.5))
                                            .cornerRadius(10)
                                    }
                                }

                                if let error = recordingError {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundColor(.red)
                                        Text(error)
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.red)
                                    }
                                    .padding(10)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(16)
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(14)

                            // AI Mode Toggle with modern styling
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.purple)
                                    .frame(width: 32, height: 32)
                                    .background(Color.purple.opacity(0.1))
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("AI Task Generation")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text("Generate tasks with ChatGPT AI")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray)
                                }

                                Spacer()
                                Toggle("", isOn: $useAI)
                            }
                            .padding(14)
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)

                            // Pro Tip
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                    Text("Pro Tip")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.orange)
                                }
                                Text("Be specific in your prompt. For example: \"Plan a 50-person birthday party\" generates better tasks than \"Plan a party\"")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                                    .lineLimit(3)
                            }
                            .padding(12)
                            .background(Color.orange.opacity(0.05))
                            .cornerRadius(10)

                            Spacer()
                                .frame(height: 8)
                        }
                        .padding(16)
                    }

                    // Generate Questions Button
                    VStack(spacing: 12) {
                        Button(action: generateQuestions) {
                            HStack(spacing: 8) {
                                if appState.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                Text(appState.isLoading ? "Generating Tasks..." : "Generate Questions")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(
                                isInputValid && !appState.isLoading ?
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue,
                                        Color.blue.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.gray.opacity(0.4),
                                        Color.gray.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!isInputValid || appState.isLoading)

                        Text("No account needed • All data saved locally")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                }
            }
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
