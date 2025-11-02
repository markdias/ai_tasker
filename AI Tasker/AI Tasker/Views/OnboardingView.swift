import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentStep: Int = 0
    @State private var apiKeyProvided: Bool = false
    @State private var apiKeyInput: String = ""
    @State private var showAPIKeyInput: Bool = false
    @State private var apiKeySaved: Bool = false
    @State private var apiSaveMessage: String = ""

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(20)

                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Welcome
                    welcomeStep
                        .tag(0)

                    // Step 2: How It Works
                    howItWorksStep
                        .tag(1)

                    // Step 3: API Setup
                    apiSetupStep
                        .tag(2)

                    // Step 4: Reminders
                    remindersSetupStep
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // Navigation Buttons
                HStack(spacing: 16) {
                    Button(action: previousStep) {
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    .disabled(currentStep == 0)

                    Button(action: nextStep) {
                        Text(currentStep == 3 ? "Get Started" : "Next")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(currentStep == 2 && !apiKeyProvided)
                }
                .padding(20)
            }
        }
    }

    // MARK: - Onboarding Steps

    var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundColor(.blue)

            VStack(spacing: 12) {
                Text("Welcome to Promptodo")
                    .font(.system(size: 28, weight: .bold))

                Text("Turn your ideas into tasks with AI")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    Text("Voice or text prompts")
                        .font(.system(size: 14, weight: .regular))
                    Spacer()
                }

                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                        .frame(width: 30)
                    Text("AI-powered task generation")
                        .font(.system(size: 14, weight: .regular))
                    Spacer()
                }

                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .frame(width: 30)
                    Text("Smart project management")
                        .font(.system(size: 14, weight: .regular))
                    Spacer()
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)

            Spacer()
        }
        .padding(20)
    }

    var howItWorksStep: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("How It Works")
                    .font(.system(size: 28, weight: .bold))

                Text("4 simple steps to organize your ideas")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                stepCard(number: 1, title: "Create a Prompt", description: "Say or type what you want to accomplish")
                stepCard(number: 2, title: "Answer Questions", description: "ChatGPT asks clarifying questions to understand your needs")
                stepCard(number: 3, title: "Review Tasks", description: "Approve AI-generated tasks that match your vision")
                stepCard(number: 4, title: "Manage & Track", description: "Organize tasks, set budgets, and sync to Reminders")
            }

            Spacer()
        }
        .padding(20)
    }

    var apiSetupStep: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("Connect Your API Key")
                    .font(.system(size: 28, weight: .bold))

                Text("Get AI-powered task generation")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.center)

            if !showAPIKeyInput {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Why is this needed?")
                        .font(.system(size: 14, weight: .semibold))

                    Text("Promptodo uses ChatGPT to understand your prompts and generate smart tasks. You'll need an OpenAI API key from your account.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)

                    Text("Steps:")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Go to platform.openai.com")
                        Text("2. Sign up or log in")
                        Text("3. Create an API key")
                        Text("4. Paste it below")
                    }
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Button(action: {
                    showAPIKeyInput = true
                }) {
                    Text("Add API Key Now")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                // API Key Input Form
                VStack(alignment: .leading, spacing: 12) {
                    if apiKeySaved {
                        // Success confirmation
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("API Key Saved")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Your OpenAI API key is ready to use")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }

                            Spacer()
                        }
                        .padding(12)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)

                        Button(action: {
                            // Close the API key input form completely
                            withAnimation {
                                showAPIKeyInput = false
                                apiKeySaved = false
                                apiKeyInput = ""
                            }
                        }) {
                            Text("Done")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    } else {
                        Text("Enter your OpenAI API Key")
                            .font(.system(size: 14, weight: .semibold))

                        SecureField("sk-...", text: $apiKeyInput)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .font(.system(size: 14))

                        Text("Your API key is stored securely in your device's keychain and never sent to external servers.")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.gray)

                        HStack(spacing: 12) {
                            Button(action: {
                                showAPIKeyInput = false
                                apiKeyInput = ""
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 14, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(Color(.systemGray4))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                            }

                            Button(action: {
                                if !apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty {
                                    // Save API key to keychain
                                    KeychainManager.shared.saveAPIKey(apiKeyInput)
                                    apiKeyProvided = true
                                    apiKeySaved = true
                                }
                            }) {
                                Text("Save & Continue")
                                    .font(.system(size: 14, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            Button(action: {
                apiKeyProvided = true
            }) {
                Text("Skip for Now")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .foregroundColor(.blue)
            }

            Spacer()
        }
        .padding(20)
    }

    var remindersSetupStep: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("Sync to Apple Reminders")
                    .font(.system(size: 28, weight: .bold))

                Text("Optional: Keep tasks in sync")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 24))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Get Reminders")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Tasks sync to Apple Reminders app")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }

                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 24))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Get Notifications")
                            .font(.system(size: 14, weight: .semibold))
                        Text("iOS reminds you about due dates")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }

                HStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Stay in Sync")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Updates flow between Promptodo & Reminders")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)

            Text("You can enable this anytime in Settings.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(20)
    }

    // MARK: - Helper Views

    func stepCard(number: Int, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("\(number)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    // MARK: - Navigation

    private func previousStep() {
        withAnimation {
            currentStep -= 1
        }
    }

    private func nextStep() {
        if currentStep == 3 {
            // Mark onboarding as complete before dismissing
            // This will be handled by RootView's onDisappear
            dismiss()
        } else {
            withAnimation {
                currentStep += 1
            }
        }
    }
}

#Preview {
    OnboardingView()
}
