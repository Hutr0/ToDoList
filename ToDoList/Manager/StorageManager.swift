//
//  StorageManager.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 11.02.2021.
//

import UIKit
import CoreData

class StorageManager {
    
    static func saveObject(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    static func deleteObject(context: NSManagedObjectContext, object: Task) {
        context.delete(object)
        
        saveObject(context)
    }
}
