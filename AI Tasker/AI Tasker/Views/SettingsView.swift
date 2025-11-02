import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var remindersEnabled: Bool = false
    @State private var syncMessage: String?
    @State private var isSyncing: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // API Settings Section
                Section(header: Text("API Configuration")) {
                    NavigationLink(destination: APISettingsView()) {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("OpenAI API Key")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Manage your ChatGPT API key")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Reminders Sync Section
                Section(header: Text("Apple Reminders")) {
                    Toggle(isOn: $remindersEnabled) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sync to Reminders")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Sync tasks to Apple Reminders")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onChange(of: remindersEnabled) { newValue in
                        if newValue {
                            requestRemindersAccess()
                        }
                    }

                    if remindersEnabled {
                        Text("Your tasks will be synced to the 'Promptodo' calendar in Apple Reminders.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }

                // App Information Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                            .font(.system(size: 16, weight: .regular))
                        Spacer()
                        Text("1.0.0")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Build")
                            .font(.system(size: 16, weight: .regular))
                        Spacer()
                        Text("M1-M6")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Developer")
                            .font(.system(size: 16, weight: .regular))
                        Spacer()
                        Text("Mark Dias")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }

                // Help Section
                Section(header: Text("Help")) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("How to Use")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Learn how to use Promptodo")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
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
