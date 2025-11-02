//
//  Project+CoreDataProperties.swift
//  AI Tasker
//
//  Created by Mark Dias on 01/11/2025.
//

import Foundation
import CoreData

extension Project {

    @NSManaged public var title: String?
    @NSManaged public var projectDescription: String?
    @NSManaged public var color: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var isArchived: NSNumber?
    @NSManaged public var dueDate: Date?
    @NSManaged public var tasks: NSSet?

    // MARK: - Helper Properties
    @objc(isArchivedValue)
    public var isArchivedValue: Bool {
        get {
            return isArchived?.boolValue ?? false
        }
        set {
            isArchived = NSNumber(value: newValue)
        }
    }

    // MARK: - Computed Properties
    public var taskArray: [Task] {
        let set = tasks as? Set<Task> ?? []
        return set.sorted { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }
    }
}

// MARK: Generated accessors for tasks
extension Project {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension Project: Identifiable {

}
