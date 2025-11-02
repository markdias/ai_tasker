//
//  TaskField+CoreDataProperties.swift
//  AI Tasker
//
//  Created by Mark Dias on 02/11/2025.
//

import Foundation
import CoreData

extension TaskField {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskField> {
        NSFetchRequest<TaskField>(entityName: "TaskField")
    }

    @NSManaged public var fieldName: String
    @NSManaged public var fieldType: String
    @NSManaged public var fieldValue: String?
    @NSManaged public var fieldOrder: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var task: Task?  // Optional relationship
}

extension TaskField: Identifiable {}
