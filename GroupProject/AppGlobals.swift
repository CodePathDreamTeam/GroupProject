//
//  AppGlobals.swift
//  GroupProject
//
//  Created by Nana on 5/7/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation
import CoreData

let Globals = AppGlobals.shared

class AppGlobals {

    // Singleton object
    static let shared = AppGlobals()
    // Restrict instantiation in rest of the app module
    private init() {}

    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CustomEntities")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                let error = APIError.ReasonableError(error.localizedDescription)
                print("Context Save Error: \(error.localizedDescription)")
            }
        })
        return container
    }()

    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Functional

    func fetch(_ request: NSFetchRequest<NSManagedObject>) -> Result<[NSManagedObject]> {

        let result: Result<[NSManagedObject]>

        do {
            result = Result.success(try managedContext.fetch(request))
        } catch {
            result = Result.failure(APIError.ReasonableError(error.localizedDescription))
        }

        return result
    }

    func saveContext () {
        if managedContext.hasChanges {
            do {
                try managedContext.save()
            } catch {
                let error = APIError.ReasonableError(error.localizedDescription)
                print("Context Save Error: \(error.localizedDescription)")
            }
        }
    }
}
