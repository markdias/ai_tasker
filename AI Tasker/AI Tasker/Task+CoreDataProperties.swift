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
}

extension Task: Identifiable {}
