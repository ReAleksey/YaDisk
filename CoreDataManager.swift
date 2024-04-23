//
//  CoreDataManager.swift
//  YaDisk
//
//  Created by Алексей Решетников on 05.04.2024.
//

import Foundation
import CoreData

class CoreDataManager {
    static let instance = CoreDataManager()
    
    lazy var context: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    // Описание сущности
    func entityForName(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }
    private init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveResource(_ resource: Resource) {
        let newFileCell = FilesCell(context: self.context)
        newFileCell.name = resource.name
        newFileCell.size = Int64(resource.size ?? 0)
//        newFileCell.created = resource.created // Здесь может потребоваться преобразование строки в дату, если created передаётся как String
//        newFileCell.publicKey = resource.public_key // Сохранение уникального ключа

        self.saveContext()
    }
    
    func fileExists(name: String) -> Bool {
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FilesCell")
         fetchRequest.predicate = NSPredicate(format: "name == %@", name)
         let count = try? context.count(for: fetchRequest)
         return count ?? 0 > 0
     }
}
