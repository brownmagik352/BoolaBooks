//
//  SearchViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/2/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        /* FB SHARE BUTTON */
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "https://www.boolabooks.com") as URL! // going to rely on favicon from website for image?
        content.contentTitle = "I joined BoolaBooks!"
        content.contentDescription = "BoolaBooks is a new app for buying & selling textbooks at Yale."
        let shareButton = FBSDKShareButton()
        shareButton.shareContent = content;
        shareButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - (self.tabBarController?.tabBar.frame.size.height)! - shareButton.frame.width)
        view.addSubview(shareButton)
        
        // listen for events on this field
        self.searchField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // only enable search if there is a query
    override func viewWillAppear(_ animated: Bool) {
        if self.searchField.text == "" {
            self.searchButton.isEnabled = false
        } else {
            self.searchButton.isEnabled = true
        }
    }
    
    // update search button status if there is a query
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.searchField.text == "" {
            self.searchButton.isEnabled = false
        } else {
            self.searchButton.isEnabled = true
        }
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
