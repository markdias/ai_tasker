//
//  Persistence.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Create sample tasks
        let sampleTasks = [
            ("Draft presentation slides", "Create 15 slides for tomorrow's meeting", 45, "work", "high"),
            ("Rehearse speech", "Practice the presentation out loud twice", 30, "work", "high"),
            ("Make grocery list", "Plan meals and list items needed", 15, "personal", "medium"),
            ("Go to supermarket", "Shop for groceries from the list", 60, "personal", "medium"),
            ("Study math chapter 5", "Read and complete exercises", 90, "study", "high"),
            ("Review notes", "Go through last week's notes", 45, "study", "medium")
        ]

        for (title, desc, time, category, priority) in sampleTasks {
            let newTask = Task(context: viewContext)
            newTask.title = title
            newTask.taskDescription = desc
            newTask.estimatedTime = Int16(time)
            newTask.priority = priority
            newTask.category = category
            newTask.isCompletedFlag = false
            newTask.createdAtValue = Date()
            newTask.updatedAtValue = Date()
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "AI_Tasker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
