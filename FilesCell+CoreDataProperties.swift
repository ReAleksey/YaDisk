//
//  FilesCell+CoreDataProperties.swift
//  YaDisk
//
//  Created by Алексей Решетников on 05.04.2024.
//
//

import Foundation
import CoreData


extension FilesCell {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FilesCell> {
        return NSFetchRequest<FilesCell>(entityName: "FilesCell")
    }

    @NSManaged public var created: Date?
    @NSManaged public var name: String
    @NSManaged public var size: Int64
    
}

extension FilesCell : Identifiable {

}
