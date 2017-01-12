//
//  SearchViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/2/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var searchField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Dismiss KB  - touch outside the field after editing has started
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchField.resignFirstResponder()
        self.view.endEditing(true)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Don't send data if going to Settings Page
        if segue.identifier == "aboutSegue" {
            return
        }
        let destinationVC = segue.destination as! SearchResultsTableViewController
        destinationVC.searchQuery = searchField.text!
    }
    

}
