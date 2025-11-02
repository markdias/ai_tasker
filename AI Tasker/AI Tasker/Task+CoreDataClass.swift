//
//  Task+CoreDataClass.swift
//  AI Tasker
//
//  Created by Codex on 01/11/2025.
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue("Untitled Task", forKey: "title")
        setPrimitiveValue(Date(), forKey: "createdAt")
        setPrimitiveValue(Date(), forKey: "updatedAt")
        setPrimitiveValue(NSNumber(value: false), forKey: "isCompleted")
    }

    public var isCompletedFlag: Bool {
        get { isCompleted?.boolValue ?? false }
        set { isCompleted = NSNumber(value: newValue) }
    }

    public var createdAtValue: Date {
        get { createdAt ?? Date() }
        set { createdAt = newValue }
    }

    public var updatedAtValue: Date {
        get { updatedAt ?? Date() }
        set { updatedAt = newValue }
    }
}
