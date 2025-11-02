//
//  Task+CoreDataProperties.swift
//  AI Tasker
//
//  Created by Codex on 01/11/2025.
//

import Foundation
import CoreData

extension Task {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var title: String
    @NSManaged public var taskDescription: String?
    @NSManaged public var estimatedTime: Int16
    @NSManaged public var priority: String?
    @NSManaged public var isCompleted: NSNumber?
    @NSManaged public var category: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var scheduledTime: Date?
    @NSManaged public var sessionId: String?
    @NSManaged public var project: Project?

    // MARK: - Helper Properties
    @objc(isCompletedValue)
    public var isCompletedValue: Bool {
        get {
            return isCompleted?.boolValue ?? false
        }
        set {
            isCompleted = NSNumber(value: newValue)
        }
    }

    @objc(createdAtValue)
    public var createdAtValue: Date {
        return createdAt ?? Date()
    }

    @objc(updatedAtValue)
    public var updatedAtValue: Date {
        get {
            return updatedAt ?? Date()
        }
        set {
            updatedAt = newValue
        }
    }

    @objc(isCompletedFlag)
    public var isCompletedFlag: Bool {
        return isCompleted?.boolValue ?? false
    }
}

extension Task: Identifiable {}
