//
//  ListItem+CoreDataProperties.swift
//  AI Tasker
//
//  Created by Mark Dias on 02/11/2025.
//

import Foundation
import CoreData

extension ListItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        NSFetchRequest<ListItem>(entityName: "ListItem")
    }

    @NSManaged public var itemData: String
    @NSManaged public var itemOrder: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var field: TaskField?
}

extension ListItem: Identifiable {}
