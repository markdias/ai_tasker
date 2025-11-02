//
//  TaskField+CoreDataClass.swift
//  AI Tasker
//
//  Created by Mark Dias on 02/11/2025.
//

import Foundation
import CoreData

@objc(TaskField)
public class TaskField: NSManagedObject {
    public enum FieldType: String {
        case text
        case number
        case list
        case date
        case toggle

        var displayName: String {
            switch self {
            case .text:
                return "Text"
            case .number:
                return "Number"
            case .list:
                return "List"
            case .date:
                return "Date"
            case .toggle:
                return "Toggle"
            }
        }
    }

    public var fieldTypeValue: FieldType {
        get {
            FieldType(rawValue: fieldType ?? "text") ?? .text
        }
        set {
            fieldType = newValue.rawValue
        }
    }

    public var createdAtValue: Date {
        get { createdAt ?? Date() }
        set { createdAt = newValue }
    }
}
