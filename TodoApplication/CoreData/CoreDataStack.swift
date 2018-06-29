//
//  CoreDataStack.swift
//  TodoApplication
//
//  Created by Tatsuya Moriguchi on 6/29/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import Foundation
import CoreData

// MARK: ??? Separating Core Data code in this different file is new to me.

class CoreDataStack {
    
    // Create NSPersistentContainer which tracks core data model
    // MARK: ???
    // var with {} is not one I used to. Too advance to me.
    // Learn what this means.
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Todos")
        // MARK: ???
        // what does container.loadPersisttenStore do and why
        // description, error follow?
        // And what error code after 'in' is doing and why uses 'in' here?
        // MARK: - ANSWER
        // container.loadPersistentStores is responsible for loading
        // our data model and setting up a store to save our todos to disk.
        // 9 out of 10 times, an error won't occur, but it does when you mispelled
        // datamodel name "Todos" or user error where you run out of storage on phone
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        return container
    }
    // NSManagedObjectContext is responsible for managing (saving, deleting) a collection
    // of managed objects(todos), state of our data model.
    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
}
