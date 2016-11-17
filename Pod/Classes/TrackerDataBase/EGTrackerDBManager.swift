//
//  EGTrackerDBManager.swift
//  TinyGoi
//
//  Created by Miguel Chaves on 26/02/16.
//  Copyright © 2016 E-Goi. All rights reserved.
//

import UIKit
import CoreData

class EGTrackerDBManager: NSObject {
    
    // MARK: - Class Properties
    
    var managedObjectContext: NSManagedObjectContext
    var managedObjectModel: NSManagedObjectModel
    var persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    // MARK: - Init class
    
    override init() {
        self.managedObjectModel = NSManagedObjectModel.init(contentsOfURL: EGTrackerDBManager.getModelUrl())!
        
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: self.managedObjectModel)
        
        do {
            try self.persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil,
                URL: EGTrackerDBManager.storeURL(), options: nil)
        } catch let error as NSError {
            print(error)
            abort()
        }
        
        self.managedObjectContext = NSManagedObjectContext.init(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        self.managedObjectContext.mergePolicy = NSOverwriteMergePolicy
    }
    
    // MARK: - Shared Instance
    
    class var sharedInstance: EGTrackerDBManager {
        struct Singleton {
            static let instance = EGTrackerDBManager()
        }
        
        return Singleton.instance
    }
    
    // MARK: - Create and Save objects
    
    func managedObjectOfType(objectType: String) -> NSManagedObject {
        let newObject = NSEntityDescription.insertNewObjectForEntityForName(objectType,
            inManagedObjectContext: self.managedObjectContext)
        
        return newObject
    }
    
    func saveContext() {
        if (!self.managedObjectContext.hasChanges) {
            return
        } else {
            do {
                try self.managedObjectContext.save()
            } catch let exception as NSException {
                print("Error while saving \(exception.userInfo) : \(exception.reason)")
            } catch {
                print("Error while saving data!")
            }
        }
    }
    
    // MARK: - Retrieve data
    
    func allEntriesOfType(objectType: String) -> [AnyObject] {
        let entety = NSEntityDescription.entityForName(objectType,
            inManagedObjectContext: self.managedObjectContext)
        
        let request = NSFetchRequest.init()
        request.entity = entety
        request.includesPendingChanges = true
        
        do {
            let result = try self.managedObjectContext.executeFetchRequest(request)
            return result
        } catch {
            print("Error executing request in the Data Base")
        }
        
        return []
    }
    
    func getEntryOfType(objectType: String, propertyName: String, propertyValue: AnyObject) -> [AnyObject] {
        let entety = NSEntityDescription.entityForName(objectType,
            inManagedObjectContext: self.managedObjectContext)
        
        let request = NSFetchRequest.init()
        request.entity = entety
        request.includesPendingChanges = true
        
        let predicate = NSPredicate(format: "\(propertyName) == \(propertyValue)")
        request.predicate = predicate
        
        do {
            let result = try self.managedObjectContext.executeFetchRequest(request)
            var returnArray: [AnyObject] = [AnyObject]()
            
            for element in result {
                returnArray.append(element)
            }
            
            return returnArray
        } catch {
            print("Error executing request in the Data Base")
        }
        
        return []
    }
    
    func deleteAllEntriesOfType(objectType: String) {
        let elements = allEntriesOfType(objectType)
        
        if (elements.count > 0) {
            for element in elements {
                self.managedObjectContext.deleteObject(element as! NSManagedObject)
            }
            
            saveContext()
        }
    }
    
    func deleteObject(object: NSManagedObject) {
        self.managedObjectContext.deleteObject(object)
        saveContext()
    }
    
    // MARK: - Private functions
    
    static private func getModelUrl() -> NSURL {
        return NSBundle.mainBundle().URLForResource("TrackerDataBase", withExtension: "mom")!
    }
    
    static private func storeURL () -> NSURL? {
        
        let applicationDocumentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
        let storeUrl = applicationDocumentsDirectory?.URLByAppendingPathComponent("TrackerDataBase.sqlite")
        
        return storeUrl
    }
}
