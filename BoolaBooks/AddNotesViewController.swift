//
//  AddNotesViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/16/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit

class AddNotesViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var newNotesField: UITextView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var delegate: ModalViewControllerDelegate! // need this to send back data back from modal, guaranteed by uploadVC's prepare segue
    var placeholderString = "Notes are a great way to provide extra information to buyers.\n\nPlease know that adding notes is entirely optional."

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newNotesField.text = self.placeholderString
        self.addButton.isEnabled = false
        self.newNotesField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.addButton.isEnabled = true
    }
    
    // Dismiss KB  - touch outside the field after editing has started
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        newNotesField.resignFirstResponder()
        self.view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        // sending only one course back
        self.delegate.sendModalValue2(value: self.newNotesField.text)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

}
