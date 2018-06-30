//
//  TodoTableViewController.swift
//  TodoApplication
//
//  Created by Tatsuya Moriguchi on 6/28/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData


class TodoTableViewController: UITableViewController {

    // MARK: - Properties for Core Data
    // NSFetchedResultsController is responsible for manageging our managedobjects (todos)
    // and update our table view.
    var resultsController: NSFetchedResultsController<Todo>!
    
    // use coreDataStack to initialize resultsController below
    let coreDataStack = CoreDataStack()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Request
        // Use following contstants to initialize resultsController
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptors]
        
        //Initialize resultsController for Core Data
        // fetchRequest is how we get todos
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        // In oder to update table view cell for newly added data
        // tell resultsController is delegate.
        resultsController.delegate = self
      
        // Fetch
        do {
            try resultsController.performFetch()
        }catch{
            print("Perform fetch error: \(error)")
        }
    }

    // MARK: - Table view data source
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
*/
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // MARK: ???
        // Never seen this way below. resultsController is our data source now.
        // what 'sections?[section].objects?' is doing here?
        // return resultsController.sections?[section].objects?.count ?? 0
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)

        // Configure the cell...
        let todo = resultsController.object(at: indexPath)
        cell.textLabel?.text = todo.title

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            // TODO: Delete todo
            // get the object to delete first
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            // Tell managed obejct context of the change
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            }catch{
                print("delete failed: \(error)")
                completion(false)
            }
        }
        action.image = #imageLiteral(resourceName: "trash")
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: ([action]))
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Check") { (action, view, completion) in
            // TODO: Check and delete todo
            // get the object to check first
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            // Tell managed obejct context of the change
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            }catch{
                print("delete failed: \(error)")
                completion(false)
            }
        }
        action.image = #imageLiteral(resourceName: "check")
        action.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: ([action]))
        
    }

    // Add a delegate method to send to AddTodoVC when a cell is selected,
    // and then update todo
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowAddTodo", sender: tableView.cellForRow(at: indexPath))
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Initialize managedContext on a second modal controller
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddTodoViewController {
            //vc.managedContext = coreDataStack.managedContext this is a mistake.
            vc.managedContext = resultsController.managedObjectContext
        }
        
        // To update todo cell, send to AddTodoViewController when a cell is selected
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                let todo = resultsController.object(at: indexPath)
                vc.todo = todo
            }
        }
    }
}

// MARK: - Update table view cell for newly added data
extension TodoTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let todo = resultsController.object(at: indexPath)
                cell.textLabel?.text = todo.title
            }
            
        default:
            break
        }
    }
}
