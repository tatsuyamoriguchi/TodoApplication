//
//  AddTodoViewController.swift
//  TodoApplication
//
//  Created by Tatsuya Moriguchi on 6/28/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class AddTodoViewController: UIViewController {

    // MARK: - Properties
    var managedContext: NSManagedObjectContext!
    
    //MARK: OUTLETS
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(with:)),
            name: .UIKeyboardWillShow,
            object: nil)
        
        textView.becomeFirstResponder()
    }

    // MARK: ACTIONS
    @objc func keyboardWillShow(with notification: Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height + 16
        bottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }

    @IBAction func cancel(_ sender: UIButton) {
        dismissAndResign()
    }
    
    @IBAction func done(_ sender: UIButton) {
        guard let title = textView.text, !title.isEmpty else {
            return
            // Alert user tat you can't save data without text as an error
        }
        let todo = Todo(context: managedContext)
        todo.title = title
        todo.priority = Int16(segmentedControl.selectedSegmentIndex)
        todo.date = Date()
        
        // Tell managedContext to save this
        do {
            try managedContext.save()
            dismissAndResign()
        }catch{
            print("Saving error \(error)")
        }
    }
}

extension AddTodoViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if doneButton.isHidden {
            textView.text.removeAll()
            textView.textColor = .white
            doneButton.isHidden = false
            //UIView.animate(withDuration: 0.3, animations: {
            UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            //})
        
            }
        }
    }
}
