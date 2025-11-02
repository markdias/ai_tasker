//
//  ProjectsView.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import SwiftUI
import CoreData

struct ProjectsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingNewProject = false
    @State private var selectedProject: Project?
    @State private var showingProjectDetail = false

    @FetchRequest(
        entity: Project.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.createdAt, ascending: false)],
        predicate: NSPredicate(format: "isArchived == false"),
        animation: .default)
    private var activeProjects: FetchedResults<Project>

    @FetchRequest(
        entity: Project.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.createdAt, ascending: false)],
        predicate: NSPredicate(format: "isArchived == true"),
        animation: .default)
    private var archivedProjects: FetchedResults<Project>

    var body: some View {
        NavigationStack {
            ZStack {
                if activeProjects.isEmpty && archivedProjects.isEmpty {
                    emptyStateView
                } else {
                    projectsList
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewProject = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewProject) {
            ProjectCreationView()
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingProjectDetail) {
            if let project = selectedProject {
                ProjectDetailView(project: project)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .opacity(0.5)
            Text("No Projects Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Create your first project to organize tasks")
                .foregroundColor(.secondary)
            Button(action: { showingNewProject = true }) {
                Label("New Project", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 40)
    }

    var projectsList: some View {
        List {
            if !activeProjects.isEmpty {
                Section(header: Text("Active Projects")) {
                    ForEach(activeProjects) { project in
                        ProjectRow(project: project, isArchived: false)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedProject = project
                                showingProjectDetail = true
                            }
                    }
                    .onDelete(perform: deleteProject)
                }
            }

            if !archivedProjects.isEmpty {
                Section(header: Text("Archived Projects")) {
                    ForEach(archivedProjects) { project in
                        ProjectRow(project: project, isArchived: true)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedProject = project
                                showingProjectDetail = true
                            }
                    }
                    .onDelete(perform: deleteArchivedProject)
                }
            }
        }
    }

    private func deleteProject(offsets: IndexSet) {
        withAnimation {
            offsets.map { activeProjects[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting project: \(error)")
            }
        }
    }

    private func deleteArchivedProject(offsets: IndexSet) {
        withAnimation {
            offsets.map { archivedProjects[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting archived project: \(error)")
            }
        }
    }
}

struct ProjectRow: View {
    @ObservedObject var project: Project
    let isArchived: Bool

    var completionPercentage: Double {
        guard let tasks = project.tasks, tasks.count > 0 else { return 0 }
        let completedCount = tasks.filter { ($0 as? Task)?.isCompletedFlag == true }.count
        return Double(completedCount) / Double(tasks.count) * 100
    }

    var taskCount: Int {
        project.tasks?.count ?? 0
    }

    var completedCount: Int {
        project.tasks?.filter { ($0 as? Task)?.isCompletedFlag == true }.count ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.title ?? "Untitled Project")
                        .font(.headline)
                        .strikethrough(isArchived, color: .gray)
                        .foregroundColor(isArchived ? .gray : .primary)

                    if let description = project.projectDescription {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(completedCount)/\(taskCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    if let dueDate = project.dueDate {
                        HStack(spacing: 2) {
                            Image(systemName: "calendar")
                            Text(dueDate, style: .date)
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }

            if taskCount > 0 {
                HStack(spacing: 8) {
                    ProgressView(value: completionPercentage, total: 100)
                        .tint(.blue)

                    Text(String(format: "%.0f%%", completionPercentage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProjectDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var project: Project
    @State private var projectTitle: String = ""
    @State private var projectDescription: String = ""
    @State private var projectDueDate: Date?
    @State private var showAlert = false
    @State private var alertMessage = ""

    var projectTasks: [Task] {
        (project.tasks as? Set<Task>)?.sorted { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) } ?? []
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project Name", text: $projectTitle)
                    TextEditor(text: $projectDescription)
                        .frame(height: 80)
                    DatePicker("Due Date", selection: Binding(
                        get: { projectDueDate ?? Date() },
                        set: { projectDueDate = $0 }
                    ), displayedComponents: [.date])
                }

                Section(header: Text("Tasks (\(projectTasks.count))")) {
                    if projectTasks.isEmpty {
                        Text("No tasks in this project")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(projectTasks) { task in
                            TaskListRow(task: task)
                        }
                        .onDelete { indexSet in
                            deleteTasksAtIndexSet(indexSet, from: projectTasks)
                        }
                    }
                }

                Section {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Archive Project", role: .destructive) {
                        archiveProject()
                    }

                    Button("Delete Project", role: .destructive) {
                        deleteProject()
                    }
                }
            }
            .navigationTitle("Project Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                projectTitle = project.title ?? ""
                projectDescription = project.projectDescription ?? ""
                projectDueDate = project.dueDate
            }
            .alert("Success", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func saveChanges() {
        withAnimation {
            project.title = projectTitle.isEmpty ? "Untitled Project" : projectTitle
            project.projectDescription = projectDescription
            project.dueDate = projectDueDate
            project.updatedAt = Date()

            do {
                try viewContext.save()
                alertMessage = "Project updated successfully"
                showAlert = true
            } catch {
                let nsError = error as NSError
                alertMessage = "Error saving project: \(nsError.localizedDescription)"
                showAlert = true
            }
        }
    }

    private func archiveProject() {
        project.isArchived = true
        project.updatedAt = Date()

        do {
            try viewContext.save()
            dismiss()
        } catch {
            alertMessage = "Error archiving project: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func deleteProject() {
        viewContext.delete(project)

        do {
            try viewContext.save()
            dismiss()
        } catch {
            alertMessage = "Error deleting project: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func deleteTasksAtIndexSet(_ indexSet: IndexSet, from tasks: [Task]) {
        withAnimation {
            indexSet.forEach { index in
                viewContext.delete(tasks[index])
            }

            do {
                try viewContext.save()
            } catch {
                alertMessage = "Error deleting task: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

struct TaskListRow: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack(spacing: 12) {
            Button(action: toggleCompletion) {
                Image(systemName: task.isCompletedFlag ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.isCompletedFlag ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompletedFlag, color: .gray)
                    .foregroundColor(task.isCompletedFlag ? .gray : .primary)

                if let desc = task.taskDescription {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    if task.estimatedTime > 0 {
                        Label("\(task.estimatedTime)m", systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    if let priority = task.priority {
                        Label(priority, systemImage: "flag")
                            .font(.caption2)
                            .foregroundColor(priorityColor(priority))
                    }
                }
            }

            Spacer()
        }
    }

    private func toggleCompletion() {
        withAnimation {
            task.isCompletedFlag.toggle()
            task.updatedAtValue = Date()

            do {
                try viewContext.save()
            } catch {
                print("Error toggling task: \(error)")
            }
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

#Preview {
    ProjectsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
