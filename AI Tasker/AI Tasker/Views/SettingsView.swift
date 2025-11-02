import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var remindersEnabled: Bool = false
    @State private var syncMessage: String?
    @State private var isSyncing: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with gradient background
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings")
                                .font(.system(size: 26, weight: .bold))
                            Text("Customize your experience")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(8)
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

                    ScrollView {
                        VStack(spacing: 18) {
                            // API Settings Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "gearshape.2.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.blue)
                                    Text("API Configuration")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }

                                NavigationLink(destination: APISettingsView()) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "key.fill")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.blue)
                                            .frame(width: 32, height: 32)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("OpenAI API Key")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.primary)
                                            Text("Manage your ChatGPT API key")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray.opacity(0.6))
                                    }
                                    .padding(12)
                                    .background(Color(.systemGray6).opacity(0.5))
                                    .cornerRadius(10)
                                }
                            }

                            // Reminders Sync Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.orange)
                                    Text("Apple Reminders")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }

                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.green)
                                        .frame(width: 32, height: 32)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Sync to Reminders")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Text("Sync tasks to Apple Reminders")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()
                                    Toggle("", isOn: $remindersEnabled)
                                        .onChange(of: remindersEnabled) { newValue in
                                            if newValue {
                                                requestRemindersAccess()
                                            }
                                        }
                                }
                                .padding(12)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(10)

                                if remindersEnabled {
                                    Text("Your tasks will be synced to the 'Promptodo' calendar in Apple Reminders.")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 2)
                                }
                            }

                            // App Information Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.purple)
                                    Text("About")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }

                                VStack(spacing: 10) {
                                    HStack {
                                        Text("Version")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("1.0.0")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(10)
                                    .background(Color(.systemGray6).opacity(0.3))
                                    .cornerRadius(8)

                                    HStack {
                                        Text("Build")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("M1-M6")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(10)
                                    .background(Color(.systemGray6).opacity(0.3))
                                    .cornerRadius(8)

                                    HStack {
                                        Text("Developer")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("Mark Dias")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(10)
                                    .background(Color(.systemGray6).opacity(0.3))
                                    .cornerRadius(8)
                                }
                                .padding(12)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(10)
                            }

                            Spacer()
                                .frame(height: 8)
                        }
                        .padding(16)
                    }

                    if let message = syncMessage {
                        VStack {
                            Text(message)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.green)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    private func requestRemindersAccess() {
        RemindersService.shared.requestRemindersAccess { granted, error in
            if granted {
                syncMessage = "✅ Reminders access granted"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    syncMessage = nil
                }
            } else if let error = error {
                syncMessage = "❌ Failed to access Reminders: \(error.localizedDescription)"
                remindersEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    syncMessage = nil
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
