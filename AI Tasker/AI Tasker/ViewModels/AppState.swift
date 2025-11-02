import Foundation
import Observation
import SwiftData
import EventKit

/// Navigation flow states
enum AppFlow: Equatable {
    case onboarding
    case home
    case questionForm
    case taskReview
    case projectDashboard
}

/// Global application state
@Observable
class AppState {
    // MARK: - Navigation
    var currentFlow: AppFlow = .home
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding")
        }
    }

    // MARK: - Session State (transient during flow)
    var currentPrompt: PromptLocal?
    var currentQuestions: [QuestionCard] = []
    var currentAnswers: [String] = Array(repeating: "", count: 5)
    var generatedTasks: [GeneratedTaskModel] = []

    // MARK: - UI State
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Settings
    private let keychainManager = KeychainManager.shared

    init() {
        // Show onboarding on first launch
        if !hasCompletedOnboarding {
            currentFlow = .onboarding
        }
    }

    // MARK: - Navigation Methods

    func navigateTo(_ flow: AppFlow) {
        currentFlow = flow
    }

    func resetFlow() {
        currentFlow = .home
        currentPrompt = nil
        currentQuestions = []
        currentAnswers = Array(repeating: "", count: 5)
        generatedTasks = []
        clearError()
    }

    // MARK: - Prompt Methods

    func setPrompt(_ text: String, voiceDataURL: String? = nil) {
        let prompt = PromptLocal(
            text: text,
            voiceDataURL: voiceDataURL,
            status: "pending"
        )
        currentPrompt = prompt
    }

    func generateMockQuestions() {
        // M1: Mock questions for testing
        currentQuestions = [
            QuestionCard(index: 1, text: "What's the occasion or main goal?"),
            QuestionCard(index: 2, text: "How many people are involved?"),
            QuestionCard(index: 3, text: "What's your budget (if any)?"),
            QuestionCard(index: 4, text: "What's your preferred date and time?"),
            QuestionCard(index: 5, text: "Any special requirements or constraints?"),
        ]
        navigateTo(.questionForm)
    }

    // MARK: - M2: Real AI Methods

    func generateQuestionsWithAI() {
        guard let prompt = currentPrompt?.text else {
            setError("No prompt provided")
            return
        }

        isLoading = true
        OpenAIService.shared.generateQuestions(for: prompt) { [weak self] questions, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.setError("Failed to generate questions: \(error.localizedDescription)")
                    return
                }

                guard let questions = questions, !questions.isEmpty else {
                    self?.setError("No questions generated")
                    return
                }

                self?.currentQuestions = questions
                self?.navigateTo(.questionForm)
            }
        }
    }

    func generateTasksWithAI() {
        guard let prompt = currentPrompt?.text else {
            setError("No prompt provided")
            return
        }

        isLoading = true
        OpenAIService.shared.generateTasks(for: prompt, answers: currentAnswers) { [weak self] tasks, projectTitle, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.setError("Failed to generate tasks: \(error.localizedDescription)")
                    return
                }

                guard let tasks = tasks, !tasks.isEmpty else {
                    self?.setError("No tasks generated")
                    return
                }

                self?.generatedTasks = tasks
                // Use AI-generated project title if available
                if let aiProjectTitle = projectTitle, !aiProjectTitle.isEmpty {
                    // Store for later use in TaskReviewView
                }
                self?.navigateTo(.taskReview)
            }
        }
    }

    func setAnswer(_ index: Int, answer: String) {
        if index >= 0 && index < currentAnswers.count {
            currentAnswers[index] = answer
        }
    }

    func generateMockTasks() {
        // M1: Mock tasks for testing
        currentQuestions = [] // Clear questions after answering
        generatedTasks = [
            GeneratedTaskModel(
                title: "Create Guest List",
                description: "Compile the list of guests and their contact information",
                type: "list",
                inputFields: [
                    InputFieldDefinition(name: "guest_name", label: "Guest Name", type: "text", required: true),
                    InputFieldDefinition(name: "contact_info", label: "Email or Phone", type: "text", required: false),
                ],
                isAccepted: true
            ),
            GeneratedTaskModel(
                title: "Set Budget",
                description: "Define and allocate your budget across categories",
                type: "currency",
                inputFields: [
                    InputFieldDefinition(name: "total_budget", label: "Total Budget ($)", type: "currency", required: true),
                ],
                isAccepted: true
            ),
            GeneratedTaskModel(
                title: "Schedule Date & Time",
                description: "Pick the event date and time, then send invitations",
                type: "date",
                inputFields: [
                    InputFieldDefinition(name: "event_date", label: "Date", type: "date", required: true),
                    InputFieldDefinition(name: "event_time", label: "Time", type: "text", required: false),
                ],
                isAccepted: true
            ),
        ]
        navigateTo(.taskReview)
    }

    func toggleTaskAcceptance(_ taskIndex: Int) {
        if taskIndex >= 0 && taskIndex < generatedTasks.count {
            generatedTasks[taskIndex].isAccepted.toggle()
        }
    }

    // MARK: - Project Methods

    func saveProject(title: String, modelContext: ModelContext) {
        let project = ProjectLocal(title: title)

        // Create tasks from accepted generatedTasks
        for generatedTask in generatedTasks where generatedTask.isAccepted {
            let task = TaskLocal(
                projectId: project.id,
                title: generatedTask.title,
                taskDescription: generatedTask.description,
                type: generatedTask.type
            )

            // Encode input schema
            if let schema = try? JSONEncoder().encode(
                InputSchemaDefinition(
                    fieldType: generatedTask.type,
                    itemSchema: generatedTask.type == "list" ? InputSchemaDefinition.ItemSchema(fields: generatedTask.inputFields) : nil
                )
            ) {
                task.inputSchemaJSON = String(data: schema, encoding: .utf8)
            }

            task.project = project
            project.tasks.append(task)
        }

        project.taskCount = project.tasks.count

        // Save to SwiftData
        modelContext.insert(project)
        do {
            try modelContext.save()

            // M5: Sync to Apple Reminders if enabled
            let remindersService = RemindersService.shared
            if remindersService.checkAuthorizationStatus() == .fullAccess ||
               remindersService.checkAuthorizationStatus() == .authorized {
                // Setup calendar if needed
                remindersService.setupReminderCalendar()

                // Sync project to Reminders
                remindersService.syncProjectToReminders(project: project) { reminderIds, errors in
                    // Store reminder IDs in tasks for future sync
                    if !reminderIds.isEmpty {
                        project.syncedToReminders = true
                        // Update task reminder IDs
                        for task in project.tasks {
                            if let reminderId = reminderIds[task.id] {
                                task.reminderId = reminderId
                            }
                        }
                        // Save updated project and tasks
                        do {
                            try modelContext.save()
                        } catch {
                            print("Error saving reminder IDs: \(error.localizedDescription)")
                        }
                    }

                    // Log any sync errors
                    if !errors.isEmpty {
                        print("Reminders sync errors: \(errors)")
                    }
                }
            }

            resetFlow()
            navigateTo(.projectDashboard)
        } catch {
            setError("Failed to save project: \(error.localizedDescription)")
        }
    }

    // MARK: - Error Handling

    func setError(_ message: String) {
        errorMessage = message
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - API Key Management (M2+)

    func getAPIKey() -> String? {
        keychainManager.retrieveAPIKey()
    }

    func saveAPIKey(_ key: String) {
        keychainManager.saveAPIKey(key)
    }

    func clearAPIKey() {
        keychainManager.deleteAPIKey()
    }
}
