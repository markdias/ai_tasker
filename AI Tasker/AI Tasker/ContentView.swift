//
//  ContentView.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingGoalInput = false
    @State private var showingSettings = false
    @State private var selectedTab = 0

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)],
        animation: .default)
    private var tasks: FetchedResults<Task>

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tasks Tab
            NavigationStack {
                ZStack {
                    if tasks.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "checklist")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            Text("No Tasks Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Generate tasks from your daily goal")
                                .foregroundColor(.secondary)
                            Button(action: { showingGoalInput = true }) {
                                Label("Generate Tasks", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                        .transition(.opacity)
                    } else {
                        List {
                            ForEach(tasks) { task in
                                TaskRowView(task: task)
                                    .transition(.slide)
                            }
                            .onDelete(perform: deleteTasks)
                        }
                    }
                }
                .navigationTitle("My Tasks")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingGoalInput = true }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }
            .tag(0)

            // Projects Tab
            ProjectsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
                .tag(1)

            // Stats Tab
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(2)
        }
        .sheet(isPresented: $showingGoalInput) {
            GoalInputView()
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation(.easeInOut) {
            offsets.map { tasks[$0] }.forEach { task in
                // Cancel any scheduled notifications for this task
                let taskId = task.objectID.uriRepresentation().lastPathComponent
                NotificationManager.shared.cancelTaskReminder(taskId: taskId)
                viewContext.delete(task)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting tasks: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct TaskRowView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationLink(destination: TaskDetailView(task: task).environment(\.managedObjectContext, viewContext)) {
            HStack(spacing: 12) {
                Button(action: {
                    toggleCompletion()
                }) {
                    Image(systemName: task.isCompletedFlag ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(task.isCompletedFlag ? .green : .gray)
                }
                .buttonStyle(PlainButtonStyle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompletedFlag, color: .gray)
                        .foregroundColor(task.isCompletedFlag ? .gray : .primary)

                    if let description = task.taskDescription, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: 12) {
                        if let category = task.category {
                            Label(category, systemImage: "tag")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }

                        if let priority = task.priority, !priority.isEmpty {
                            Label(priority, systemImage: priorityIcon(priority))
                                .font(.caption2)
                                .foregroundColor(priorityColor(priority))
                        }

                        if task.estimatedTime > 0 {
                            Label("\(task.estimatedTime)m", systemImage: "clock")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()
            }
        }
    }

    private func toggleCompletion() {
        withAnimation {
            task.isCompletedFlag.toggle()
            task.updatedAtValue = Date()
            do {
                try viewContext.save()
            } catch {
                print("Error saving task: \(error)")
            }
        }
    }

    private func priorityIcon(_ priority: String) -> String {
        switch priority.lowercased() {
        case "high": return "exclamationmark.circle.fill"
        case "medium": return "circle.fill"
        default: return "circle"
        }
    }

    private func priorityColor(_ priority: String) -> Color {
        switch priority.lowercased() {
        case "high": return .red
        case "medium": return .orange
        default: return .gray
        }
    }
}

struct GoalInputView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @StateObject private var appSettings = AppSettings.shared
    @State private var goalDescription = ""
    @State private var timeAvailable: Int16 = 4
    @State private var selectedPriority = "medium"
    @State private var selectedCategory = "personal"
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var useAI = true

    let priorities = ["low", "medium", "high"]
    let categories = ["work", "study", "personal", "health", "home"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Your Daily Goal")) {
                    TextEditor(text: $goalDescription)
                        .frame(height: 100)
                        .placeholder(when: goalDescription.isEmpty) {
                            Text("e.g., I want to study for my exams and clean my room")
                                .foregroundColor(.gray)
                        }
                }

                Section(header: Text("Options")) {
                    Picker("Priority Level", selection: $selectedPriority) {
                        ForEach(priorities, id: \.self) { priority in
                            Text(priority.capitalized).tag(priority)
                        }
                    }

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.capitalized).tag(category)
                        }
                    }

                    Stepper("Time Available: \(timeAvailable) hours", value: $timeAvailable, in: 1...24)
                }

                Section(header: Text("Generation")) {
                    Toggle("Use AI (ChatGPT)", isOn: $useAI)
                    if !appSettings.hasAPIKey && useAI {
                        Label("API key not configured", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Section {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Text("Generating...")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    } else {
                        Button(action: generateTasks) {
                            Text(useAI ? "Generate with AI" : "Generate Tasks")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .disabled(goalDescription.trimmingCharacters(in: .whitespaces).isEmpty || (useAI && !appSettings.hasAPIKey))
                    }
                }
            }
            .navigationTitle("New Task Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("Copy") {
                    UIPasteboard.general.string = errorMessage
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func generateTasks() {
        if useAI {
            generateTasksWithAI()
        } else {
            generateDummyTasks()
        }
    }

    private func generateTasksWithAI() {
        isLoading = true

        OpenAIManager.shared.generateTasks(
            goal: goalDescription,
            timeAvailable: Int(timeAvailable),
            category: selectedCategory,
            priority: selectedPriority
        ) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let generatedTasks):
                    saveTasks(generatedTasks.map { generatedTask in
                        (
                            title: generatedTask.title,
                            description: generatedTask.description,
                            time: generatedTask.estimatedTime,
                            priority: generatedTask.priority
                        )
                    })
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }

    private func generateDummyTasks() {
        let goalKeywords = goalDescription.lowercased()
        var generatedTasks: [(title: String, description: String?, time: Int16, priority: String)] = []

        if goalKeywords.contains("study") || goalKeywords.contains("learn") {
            generatedTasks.append(("Review study materials", "Go through notes and key concepts", 45, "high"))
            generatedTasks.append(("Complete practice problems", "Solve 10-15 relevant problems", 60, "high"))
            generatedTasks.append(("Create summary notes", "Write condensed version of important topics", 30, "medium"))
        }

        if goalKeywords.contains("clean") || goalKeywords.contains("room") || goalKeywords.contains("house") {
            generatedTasks.append(("Tidy bedroom", "Make bed and organize furniture", 20, "medium"))
            generatedTasks.append(("Vacuum and sweep floors", "Clean all floor surfaces", 30, "medium"))
            generatedTasks.append(("Put away items", "Organize clothes and personal items", 25, "low"))
        }

        if goalKeywords.contains("work") || goalKeywords.contains("project") || goalKeywords.contains("presentation") {
            generatedTasks.append(("Create presentation slides", "Draft 15-20 slides with content", 90, "high"))
            generatedTasks.append(("Prepare talking points", "Write detailed notes for each section", 45, "high"))
            generatedTasks.append(("Practice presentation", "Run through entire presentation twice", 30, "medium"))
        }

        if generatedTasks.isEmpty {
            generatedTasks.append(("Complete main task", goalDescription, Int16(timeAvailable * 60), selectedPriority))
        }

        saveTasks(generatedTasks)
    }

    private func saveTasks(_ generatedTasks: [(title: String, description: String?, time: Int16, priority: String)]) {
        let sessionId = UUID().uuidString

        withAnimation {
            for (title, description, time, priority) in generatedTasks {
                let newTask = Task(context: viewContext)
                newTask.title = title
                let trimmedDescription = description?.trimmingCharacters(in: .whitespacesAndNewlines)
                newTask.taskDescription = (trimmedDescription?.isEmpty == false) ? trimmedDescription : nil
                newTask.estimatedTime = time
                newTask.priority = priority
                newTask.category = selectedCategory
                newTask.isCompletedFlag = false
                newTask.createdAtValue = Date()
                newTask.updatedAtValue = Date()
                newTask.sessionId = sessionId
            }

            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                errorMessage = "Error saving tasks: \(nsError.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("API Configuration")) {
                    NavigationLink("API Key Setup", destination: APIKeyView())
                    NavigationLink("Model Selection", destination: ModelSelectionView())
                }

                Section(header: Text("Preferences")) {
                    NavigationLink("Task Generation Style", destination: TaskStyleView())
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct APIKeyView: View {
    @StateObject private var appSettings = AppSettings.shared
    @State private var apiKey = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("OpenAI API Key")) {
                SecureField("Enter your API key", text: $apiKey)
                Text("Your API key is stored securely in the Keychain")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if appSettings.hasAPIKey {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("API key is configured")
                            .font(.caption)
                    }
                }
            }

            Section {
                Button(action: saveAPIKey) {
                    Text("Save API Key")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(apiKey.isEmpty)

                if appSettings.hasAPIKey {
                    Button(action: removeAPIKey) {
                        Text("Remove API Key")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .navigationTitle("API Key")
        .navigationBarTitleDisplayMode(.inline)
        .alert("API Key", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    private func saveAPIKey() {
        do {
            try appSettings.saveAPIKey(apiKey)
            alertMessage = "API key saved successfully"
            apiKey = ""
            showAlert = true
        } catch {
            alertMessage = "Failed to save API key: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func removeAPIKey() {
        do {
            try appSettings.deleteAPIKey()
            alertMessage = "API key removed"
            apiKey = ""
            showAlert = true
        } catch {
            alertMessage = "Failed to remove API key: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

struct ModelSelectionView: View {
    @StateObject private var appSettings = AppSettings.shared
    let models = ["gpt-4-turbo", "gpt-4", "gpt-3.5-turbo"]

    var body: some View {
        Form {
            Section(header: Text("Select AI Model")) {
                Picker("Model", selection: $appSettings.selectedModel) {
                    ForEach(models, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
            }

            Section(footer: Text("Choose based on your needs. GPT-4 Turbo offers the best balance of cost and performance.")) {
                Text("Current: \(appSettings.selectedModel)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Model Selection")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TaskStyleView: View {
    @StateObject private var appSettings = AppSettings.shared
    let styles = ["brief", "detailed"]

    var body: some View {
        Form {
            Section(header: Text("Task Generation Style")) {
                Picker("Style", selection: $appSettings.taskStyle) {
                    ForEach(styles, id: \.self) { style in
                        Text(style.capitalized).tag(style)
                    }
                }
            }

            Section(footer: Text("Brief: Quick actionable tasks. Detailed: Includes additional context and tips.")) {
                Text("Current: \(appSettings.taskStyle.capitalized)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Task Generation Style")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
