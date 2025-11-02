//
//  ListItem+CoreDataClass.swift
//  AI Tasker
//
//  Created by Mark Dias on 02/11/2025.
//

import Foundation
import CoreData

@objc(ListItem)
public class ListItem: NSManagedObject {
    public var itemDataValue: [String: String] {
        get {
            guard let jsonStr = itemData,
                  let data = jsonStr.data(using: .utf8),
                  let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
                return [:]
            }
            return dict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let jsonStr = String(data: data, encoding: .utf8) {
                itemData = jsonStr
            }
        }
    }

    public var createdAtValue: Date {
        get { createdAt ?? Date() }
        set { createdAt = newValue }
    }
}
