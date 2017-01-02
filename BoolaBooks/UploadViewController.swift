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
    var listing: Listing?
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var conditionControl: UISegmentedControl!
    @IBOutlet weak var buyableControl: UISegmentedControl!
    @IBOutlet weak var courseField: UITextField! // not supported in route 1/2/17
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
//        uploadListing()
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
//    func uploadListing() {
//        
//        let prefs = UserDefaults.standard
//        let headers: HTTPHeaders = [
//            "X-User-Email": prefs.string(forKey: "email")!,
//            "X-User-Token": prefs.string(forKey: "rails_token")!,
//            "Content-type": "application/json",
//            "Accept": "application/json"
//        ]
//        
//        // Route currently does not define course
//        let parameters: Parameters = [
//            "listing": [
//                "publication_id": listing?.publication_id,
//                "condition": ,
//                "buyable": ,
//                "price": ,
//                "notes": "" // not supported in MVP
//            ]
//        ]
//        
//        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/auth/facebook", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
//            
//            if let result = response.result.value {
//                let JSON = result as! NSDictionary
//                
//                // save login info
//                let prefs = UserDefaults.standard
//                prefs.setValue(JSON["email"]!, forKey: "email")
//                prefs.setValue(JSON["authentication_token"]!, forKey: "rails_token")
//            }
//            
//        }
//    }
    
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
            
            // Grab and display publication info
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                
                // Grab publication ID for listing
                self.listing?.publication_id = JSON["id"] as? Int
                
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