//
//  FilesCell+CoreDataClass.swift
//  YaDisk
//
//  Created by Алексей Решетников on 05.04.2024.
//
//

import Foundation
import CoreData


public class FilesCell: NSManagedObject {

    convenience init() {
            self.init(entity: CoreDataManager.instance.entityForName(entityName: "FilesCell"), insertInto: CoreDataManager.instance.context)
        }
}
