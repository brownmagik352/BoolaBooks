//
//  UploadViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/1/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import Alamofire

// ModalViewControllerDelegate is a custom delegate that lets a modal pass back data to this VC (used for course table picker)
class UploadViewController: UIViewController, ModalViewControllerDelegate {
    
    // MARK: - Properties
    var isbn: String? // Set by Segue from ScanViewController
    var publication_id: Int?
    var courses: [String] = [] // courses to be uploaded
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var conditionControl: UISegmentedControl!
    @IBOutlet weak var buyableControl: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var addCourseButton: UIButton!
    @IBOutlet weak var uploadButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        ISBNLookup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ModalViewControllerDelegate
    func sendModalValue(value: String) {
        courses.append(value)
        addCourseButton.setTitle(value, for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upload(_ sender: UIBarButtonItem) {
        uploadListing()
        dismiss(animated: true, completion: nil)
    }
    
    // Dismiss KB  - touch outside the field after editing has started
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        priceField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CoursePickTableViewController
        destinationVC.delegate = self;
    }
    
    
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
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/listings/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if (response.result.error == nil) {
                print("**SUCCESSFUL UPLOAD**")
            }
        }

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
            
            debugPrint(response)
            
            if ((response.response?.statusCode)! == 422) {
                
                // alert the user to bad ISBN
                let alert = UIAlertController(title: "Invalid ISBN", message: "Please double check your ISBN format. We recommend using the scanner.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                // disable upload button
                self.uploadButton.isEnabled = false
                
                // bail out
                return
            } else if ((response.response?.statusCode)! == 401) {
                print("401")
                // force re-login
                return
            } else if (response.result.error == nil) {
                print("**SUCCESSFUL ISBN LOOKUP**")
            } else {
                print((response.response?.statusCode)!)
                let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, please try again later. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
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
                if let currentPublicationCourses = JSON["courses"] as? Array<String> {
                    self.courses = self.courses + (currentPublicationCourses)
                }
            }
        }
        
    }

}
