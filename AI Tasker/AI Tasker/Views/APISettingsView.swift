import SwiftUI

struct APISettingsView: View {
    @State private var apiKey: String = ""
    @State private var isShowingKey: Bool = false
    @State private var savedMessage: String?

    var hasAPIKey: Bool {
        KeychainManager.shared.hasAPIKey()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Settings")
                        .font(.system(size: 24, weight: .bold))
                    Text("Configure your OpenAI API key")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Current Status
                HStack(spacing: 12) {
                    Image(systemName: hasAPIKey ? "checkmark.circle.fill" : "circle.slash.fill")
                        .font(.system(size: 20))
                        .foregroundColor(hasAPIKey ? .green : .orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(hasAPIKey ? "API Key Configured" : "No API Key Found")
                            .font(.system(size: 14, weight: .semibold))
                        Text(hasAPIKey ? "ChatGPT AI is available" : "Add your API key to use AI features")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                // API Key Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("OpenAI API Key")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)

                    HStack(spacing: 8) {
                        if isShowingKey {
                            TextField("sk-...", text: $apiKey)
                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("sk-...", text: $apiKey)
                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                        }

                        Button(action: { isShowingKey.toggle() }) {
                            Image(systemName: isShowingKey ? "eye.slash" : "eye")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    Text("Get your API key from OpenAI")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.gray)
                }

                // Help Text
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to get your API key:")
                        .font(.system(size: 13, weight: .semibold))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("1.")
                                .foregroundColor(.gray)
                            Text("Visit platform.openai.com")
                        }
                        HStack(spacing: 8) {
                            Text("2.")
                                .foregroundColor(.gray)
                            Text("Sign up or log in")
                        }
                        HStack(spacing: 8) {
                            Text("3.")
                                .foregroundColor(.gray)
                            Text("Navigate to API keys")
                        }
                        HStack(spacing: 8) {
                            Text("4.")
                                .foregroundColor(.gray)
                            Text("Create a new secret key")
                        }
                    }
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.gray)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: saveAPIKey) {
                        Text("Save API Key")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(!apiKey.isEmpty ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(apiKey.isEmpty)

                    if hasAPIKey {
                        Button(action: deleteAPIKey) {
                            Text("Delete API Key")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                    }
                }

                if let message = savedMessage {
                    Text(message)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.green)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(16)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func saveAPIKey() {
        KeychainManager.shared.saveAPIKey(apiKey)
        savedMessage = "✅ API Key saved successfully"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            savedMessage = nil
            apiKey = ""
        }
    }

    private func deleteAPIKey() {
        KeychainManager.shared.deleteAPIKey()
        savedMessage = "❌ API Key deleted"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            savedMessage = nil
        }
    }
}

#Preview {
    APISettingsView()
}
