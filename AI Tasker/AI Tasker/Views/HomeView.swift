import SwiftUI
import Speech

struct HomeView: View {
    @State private var appState: AppState
    @State private var promptText: String = ""
    @State private var isRecording: Bool = false
    @State private var recordingError: String?
    @State private var useAI: Bool = true // Toggle between mock and real AI

    let speechRecognizer = SpeechRecognizer.shared

    private let promptSuggestions: [String] = [
        "Plan a 40th birthday weekend on a $2k budget",
        "Organize a product launch party for 75 guests",
        "Create a study sprint for finals week",
        "Design a housewarming checklist for a new apartment"
    ]

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
                            VStack(spacing: 18) {
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.blue.opacity(0.18),
                                                    Color.purple.opacity(0.16)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 18, weight: .bold))
                                                .padding(10)
                                                .background(Color.white.opacity(0.18))
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("What would you like to create?")
                                                    .font(.system(size: 18, weight: .semibold))
                                                Text("Describe your project and we'll map out the plan.")
                                                    .font(.system(size: 13, weight: .regular))
                                                    .foregroundColor(.white.opacity(0.85))
                                            }
                                        }
                                        Divider()
                                            .overlay(Color.white.opacity(0.25))
                                        Text("Paint a quick picture—include the occasion, who it's for, and any constraints you have in mind.")
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                    .padding(20)
                                    .foregroundColor(.white)
                                }
                                .overlay(
                                    Image(systemName: "circle.grid.cross.fill")
                                        .font(.system(size: 42))
                                        .foregroundColor(.white.opacity(0.15))
                                        .offset(x: 140, y: -30), alignment: .topTrailing
                                )

                                if !promptSuggestions.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Need inspiration? Try one of these")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.gray)

                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 10) {
                                                ForEach(promptSuggestions, id: \.self) { suggestion in
                                                    Button(action: {
                                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                                            promptText = suggestion
                                                        }
                                                    }) {
                                                        HStack(spacing: 6) {
                                                            Image(systemName: "quote.bubble")
                                                                .font(.system(size: 12, weight: .semibold))
                                                            Text(suggestion)
                                                                .font(.system(size: 12, weight: .semibold))
                                                        }
                                                        .padding(.horizontal, 14)
                                                        .padding(.vertical, 8)
                                                        .background(Color.blue.opacity(0.12))
                                                        .foregroundColor(.blue)
                                                        .clipShape(Capsule())
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 2)
                                        }
                                    }
                                }

                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $promptText)
                                        .frame(height: 130)
                                        .padding(12)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
                                        .font(.system(size: 16))

                                    if promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text("e.g. Plan a 3-day wellness retreat for 12 people with a $4k budget")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray.opacity(0.65))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 18)
                                    }
                                }

                                HStack(spacing: 10) {
                                    Button(action: toggleRecording) {
                                        HStack(spacing: 8) {
                                            Image(systemName: isRecording ? "waveform.circle.fill" : "mic")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text(isRecording ? "Listening..." : "Speak it out loud")
                                                .font(.system(size: 15, weight: .semibold))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .background(
                                            isRecording ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.red, Color.orange.opacity(0.9)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.blue, Color.purple.opacity(0.85)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                    .disabled(!speechRecognizer.isAvailable)

                                    Button(action: clearPrompt) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.gray.opacity(0.6))
                                            .frame(width: 48, height: 48)
                                            .background(Color(.systemGray6).opacity(0.6))
                                            .cornerRadius(12)
                                    }
                                }

                                if let error = recordingError {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                        Text(error)
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.red)
                                    }
                                    .padding(10)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(18)
                            .background(Color(.systemBackground))
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)


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
