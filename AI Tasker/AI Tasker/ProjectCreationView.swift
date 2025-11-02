//
//  ProjectCreationView.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import SwiftUI
import CoreData

struct ProjectCreationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @StateObject private var appSettings = AppSettings.shared

    @State private var step: CreationStep = .initialGoal
    @State private var goalDescription = ""
    @State private var clarifyingQuestions: [ClarifyingQuestion] = []
    @State private var answers: [String: String] = [:]
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var generatedTasks: [GeneratedTask] = []
    @State private var projectTitle = ""
    @State private var projectDueDate: Date?
    @State private var currentQuestionIndex = 0

    let clarifyingQuestionsManager = ClarifyingQuestionsManager.shared

    enum CreationStep {
        case initialGoal
        case clarifyingQuestions
        case reviewAnswers
        case generatingTasks
        case selectTasks
    }

    var body: some View {
        NavigationStack {
            ZStack {
                switch step {
                case .initialGoal:
                    initialGoalView
                case .clarifyingQuestions:
                    clarifyingQuestionsView
                case .reviewAnswers:
                    reviewAnswersView
                case .generatingTasks:
                    generatingTasksView
                case .selectTasks:
                    selectTasksView
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if step != .initialGoal {
                        Button("Back") {
                            stepBack()
                        }
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
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

    // MARK: - Step 1: Initial Goal
    var initialGoalView: some View {
        Form {
            Section(header: Text("What do you want to plan?")) {
                TextEditor(text: $goalDescription)
                    .frame(height: 120)
                    .placeholder(when: goalDescription.isEmpty) {
                        Text("e.g., I want to plan a birthday party")
                            .foregroundColor(.gray)
                    }
            }

            Section {
                Button("Continue") {
                    generateClarifyingQuestions()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(goalDescription.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    // MARK: - Step 2: Clarifying Questions
    var clarifyingQuestionsView: some View {
        Form {
            Section(header: Text("Help us understand better")) {
                if clarifyingQuestions.isEmpty {
                    Text("No questions to answer")
                        .foregroundColor(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        // Progress
                        HStack {
                            Text("Question \(currentQuestionIndex + 1) of \(clarifyingQuestions.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(clarifyingQuestions.count))
                        }

                        // Current Question
                        let question = clarifyingQuestions[currentQuestionIndex]

                        Text(question.question)
                            .font(.headline)

                        // Answer Input based on type
                        Group {
                            switch question.type {
                            case .freeText:
                                TextField("Your answer", text: Binding(
                                    get: { answers[question.question] ?? "" },
                                    set: { answers[question.question] = $0 }
                                ))
                            case .multipleChoice:
                                if let options = question.options {
                                    Picker("Select one", selection: Binding(
                                        get: { answers[question.question] ?? options.first ?? "" },
                                        set: { answers[question.question] = $0 }
                                    )) {
                                        ForEach(options, id: \.self) { option in
                                            Text(option).tag(option)
                                        }
                                    }
                                }
                            case .date:
                                DatePicker(
                                    "Select date",
                                    selection: Binding(
                                        get: {
                                            if let dateStr = answers[question.question],
                                               let date = ISO8601DateFormatter().date(from: dateStr) {
                                                return date
                                            }
                                            return Date()
                                        },
                                        set: { newDate in
                                            answers[question.question] = ISO8601DateFormatter().string(from: newDate)
                                        }
                                    ),
                                    displayedComponents: [.date]
                                )
                            case .number:
                                TextField("Enter number", text: Binding(
                                    get: { answers[question.question] ?? "" },
                                    set: { answers[question.question] = $0 }
                                ))
                                .keyboardType(.numberPad)
                            }
                        }

                        // Navigation buttons
                        HStack(spacing: 12) {
                            if currentQuestionIndex > 0 {
                                Button("Previous") {
                                    currentQuestionIndex -= 1
                                }
                                .frame(maxWidth: .infinity)
                            }

                            if currentQuestionIndex < clarifyingQuestions.count - 1 {
                                Button("Next") {
                                    currentQuestionIndex += 1
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                Button("Review") {
                                    step = .reviewAnswers
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Review Answers
    var reviewAnswersView: some View {
        Form {
            Section(header: Text("Project Details")) {
                TextField("Project Title", text: $projectTitle)
                    .placeholder(when: projectTitle.isEmpty) {
                        Text("Give your project a name")
                            .foregroundColor(.gray)
                    }

                DatePicker("Due Date (optional)", selection: Binding(
                    get: { projectDueDate ?? Date() },
                    set: { projectDueDate = $0 }
                ), displayedComponents: [.date])
            }

            Section(header: Text("Your Answers")) {
                ForEach(answers.sorted(by: { $0.key < $1.key }), id: \.key) { question, answer in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(question)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(answer)
                            .font(.body)
                    }
                }
            }

            Section {
                Button(action: generateTasks) {
                    if isLoading {
                        HStack {
                            ProgressView()
                                .tint(.white)
                            Text("Generating Tasks...")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("Generate Tasks")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(isLoading || projectTitle.isEmpty)
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - Step 4: Generating Tasks
    var generatingTasksView: some View {
        VStack(spacing: 20) {
            Spacer()

            ProgressView()
                .scaleEffect(1.5)

            Text("Generating Tasks...")
                .font(.headline)

            Text("Creating a customized task list based on your answers")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .onAppear {
            // This view appears when transition happens
        }
    }

    // MARK: - Step 5: Select Tasks
    var selectTasksView: some View {
        Form {
            Section(header: Text("Review Generated Tasks")) {
                if generatedTasks.isEmpty {
                    Text("No tasks generated")
                        .foregroundColor(.secondary)
                }

                ForEach(Array(generatedTasks.enumerated()), id: \.offset) { index, task in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.blue)
                            Text(task.title)
                                .font(.headline)
                        }

                        if let desc = task.description {
                            Text(desc)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 12) {
                            Label("\(task.estimatedTime)m", systemImage: "clock")
                                .font(.caption2)
                            Label(task.priority, systemImage: "flag")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section {
                Button(action: createProject) {
                    Text("Create Project with \(generatedTasks.count) Tasks")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - Private Methods
    private var navigationTitle: String {
        switch step {
        case .initialGoal:
            return "New Project"
        case .clarifyingQuestions:
            return "Tell Us More"
        case .reviewAnswers:
            return "Review Project"
        case .generatingTasks:
            return "Generating..."
        case .selectTasks:
            return "Generated Tasks"
        }
    }

    private func generateClarifyingQuestions() {
        isLoading = true

        clarifyingQuestionsManager.generateClarifyingQuestions(goal: goalDescription) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let questions):
                    self.clarifyingQuestions = questions
                    self.step = .clarifyingQuestions
                    self.currentQuestionIndex = 0
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
            }
        }
    }

    private func generateTasks() {
        step = .generatingTasks

        clarifyingQuestionsManager.generateTasksFromAnswers(
            goal: goalDescription,
            answers: answers
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tasks):
                    self.generatedTasks = tasks
                    self.step = .selectTasks
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                    self.step = .reviewAnswers
                }
            }
        }
    }

    private func createProject() {
        withAnimation {
            let newProject = Project(context: viewContext)
            newProject.title = projectTitle.isEmpty ? "Untitled Project" : projectTitle
            newProject.projectDescription = goalDescription
            newProject.dueDate = projectDueDate
            newProject.createdAt = Date()
            newProject.updatedAt = Date()
            newProject.color = "blue"
            newProject.isArchived = false

            // Create tasks for this project
            for task in generatedTasks {
                let newTask = Task(context: viewContext)
                newTask.title = task.title
                newTask.taskDescription = task.description
                newTask.estimatedTime = task.estimatedTime
                newTask.priority = task.priority
                newTask.isCompleted = false
                newTask.createdAt = Date()
                newTask.updatedAt = Date()
                newTask.project = newProject

                // Create dynamic fields for this task
                if let fields = task.fields {
                    for (index, field) in fields.enumerated() {
                        let newField = TaskField(context: viewContext)
                        newField.fieldName = field.fieldName
                        newField.fieldType = field.fieldType
                        newField.fieldOrder = field.fieldOrder ?? Int16(index)
                        newField.createdAt = Date()
                        newField.task = newTask
                    }
                }
            }

            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                errorMessage = "Error creating project: \(nsError.localizedDescription)"
                showErrorAlert = true
            }
        }
    }

    private func stepBack() {
        switch step {
        case .clarifyingQuestions:
            step = .initialGoal
        case .reviewAnswers:
            step = .clarifyingQuestions
            currentQuestionIndex = clarifyingQuestions.count - 1
        case .selectTasks:
            step = .reviewAnswers
        default:
            break
        }
    }
}

#Preview {
    ProjectCreationView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
