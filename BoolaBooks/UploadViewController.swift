//
//  UploadViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/1/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import Alamofire

class UploadViewController: UIViewController {
    
    // MARK: - Properties
    var isbn: String? // Set by Segue from ScanViewController
    var publication_id: Int?
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var conditionControl: UISegmentedControl!
    @IBOutlet weak var buyableControl: UISegmentedControl!
    @IBOutlet weak var courseField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        ISBNLookup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upload(_ sender: UIBarButtonItem) {
        uploadListing()
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - BoolaBooks API Calls
    
    // Upload Listing to BoolaBooks Server
    func uploadListing() {
        
        let prefs = UserDefaults.standard
        let headers: HTTPHeaders = [
            "X-User-Email": prefs.string(forKey: "email")!,
            "X-User-Token": prefs.string(forKey: "rails_token")!,
            "Content-type": "application/json",
            "Accept": "application/json"
        ]
        
        // prepare course array to be sent in params
        let courses = [courseField.text!]
        
        // Notes not supported in MVP
        let parameters: Parameters = [
            "listing": [
                "publication_id": publication_id!,
                "condition": conditionControl.titleForSegment(at: conditionControl.selectedSegmentIndex)!,
                "buyable": buyableControl.titleForSegment(at: buyableControl.selectedSegmentIndex) == "Buy",
                "price": Float(priceField.text!) ?? 0.00,
                "notes": "",
                "courses": courses
            ]
        ]
        
        /* DEBUGGING REQUEST */
        let request =  Alamofire.request("https://boolabooks.herokuapp.com/api/v1/listings/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        debugPrint(request)
        
        /*
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/listings/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if (response.result.error == nil) {
                print("**SUCCESSFUL UPLOAD**")
            }
        }
         */
    }
    
    // Using BoolaBooks API to look up a publication from an ISBN Number
    func ISBNLookup() {
        
        let prefs = UserDefaults.standard
        let headers: HTTPHeaders = [
            "X-User-Email": prefs.string(forKey: "email")!,
            "X-User-Token": prefs.string(forKey: "rails_token")!,
            "Content-type": "application/json",
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = ["isbn": self.isbn! ]
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/publications/isbn", parameters: parameters, headers: headers).responseJSON { response in
            
            if (response.result.error == nil) {
                print("**SUCCESSFUL ISBN LOOKUP**")
            }
            
            // Grab and display publication info
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                
                // Grab publication ID for listing
                self.publication_id = JSON["id"] as? Int
                
                // Display publication info
                self.titleLabel.text = JSON["title"] as? String
                self.authorLabel.text = JSON["author"] as? String
                self.yearLabel.text = JSON["year"] as? String
                self.editionLabel.text = JSON["edition"] as? String
                // Get image using URL - App Transport allows for Google Books specifically right now
                if let url  = NSURL(string: (JSON["image"] as? String)!),
                    let data = NSData(contentsOf: url as URL)
                {
                    self.bookImage.image = UIImage(data: data as Data)
                }
            }
        }
        
    }

}
