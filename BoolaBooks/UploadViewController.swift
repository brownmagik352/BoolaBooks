//
//  UploadViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/1/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKCoreKit
import FBSDKShareKit

// ModalViewControllerDelegate is a custom delegate that lets a modal pass back data to this VC (used for course table picker)
class UploadViewController: UIViewController, ModalViewControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    var isbn: String? // Set by Segue from ScanViewController
    var publication_id: Int?
    var courses: [String] = [] // courses to be uploaded
    var notes: String = "" //Notes to be uploaded
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)  // spinner to show during loading
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var conditionControl: UISegmentedControl!
    @IBOutlet weak var buyableControl: UISegmentedControl!
    @IBOutlet weak var coursesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var addCourseButton: UIButton!
    @IBOutlet weak var addNotesButton: UIButton!
    @IBOutlet weak var uploadButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Spinner Code
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.white
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.center = view.center
        self.view.addSubview(self.activityIndicator)
        
        /* FB SHARE BUTTON */
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "https://www.boolabooks.com") as URL! // going to rely on favicon from website for image?
        content.contentTitle = "I just uploaded a book on BoolaBooks!"
        content.contentDescription = "BoolaBooks is a new app for buying & selling textbooks at Yale."
        let shareButton = FBSDKShareButton()
        shareButton.shareContent = content;
        shareButton.center = CGPoint(x: self.view.frame.width-shareButton.frame.width/2, y: self.view.frame.height-shareButton.frame.height/2)
        view.addSubview(shareButton)
        
        self.activityIndicator.startAnimating()
        ISBNLookup()
        
        // listen for events on this field
        self.priceField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // when view appears, determine if price field is set and enable upload button
    override func viewWillAppear(_ animated: Bool) {
        if self.priceField.text == "" {
            self.uploadButton.isEnabled = false
        } else {
            self.uploadButton.isEnabled = true
        }
    }
    
    // enable upload button if price has been set
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.priceField.text == "" {
            self.uploadButton.isEnabled = false
        } else {
            self.uploadButton.isEnabled = true
        }
    }
    
    // ModalViewControllerDelegate
    func sendModalValue1(value: String) {
        courses.append(value)
        addCourseButton.setTitle("New Course: " + value, for: .normal)
    }
    
    func sendModalValue2(value: String) {
        notes.append(value)
        addNotesButton.setTitle("Notes Added", for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upload(_ sender: UIBarButtonItem) {
        uploadListing()
    }
    
    
    // Dismiss KB  - touch outside the field after editing has started
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        priceField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if sender as! UIButton == addCourseButton {
            let destinationVC = segue.destination as! CoursePickTableViewController
            destinationVC.delegate = self
        } else {
            let destinationVC = segue.destination as! AddNotesViewController
            destinationVC.delegate = self
            if self.notes != "" {
                destinationVC.placeholderString = self.notes
            }
        }
        
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
                "notes": self.notes,
                "courses": self.courses
            ]
        ]
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/listings/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if (response.result.error == nil) && (response.response?.statusCode == 201) {
                print("**SUCCESSFUL UPLOAD**")
                
                // alert the user to a successful upload and exit the upload modal
                let alert = UIAlertController(title: "Successful Upload", message: "Your book has been uploaded.\nBuyers can now search for your book.\nYou'll be contacted by the buyer(s) directly.", preferredStyle: UIAlertControllerStyle.alert)
                let okAction: UIAlertAction = UIAlertAction(title: "Got It",
                                                             style: .default) {
                                                                action -> Void in self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else if ((response.response?.statusCode)! == 401) {
                // present login screen on 401
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
                vc.explainString = "There was a problem with your account.\nPlease logout, log back in, and re-try your previous action."
                self.present(vc, animated: true, completion: nil)
                return
            } else {
                print((response.response?.statusCode)!)
                let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, please try again later. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
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
            
            if (response.result.error == nil) && (response.response?.statusCode)! == 200 {
                print("**SUCCESSFUL ISBN LOOKUP**")
            } else if ((response.response?.statusCode)! == 422) {
                
                // alert the user to bad ISBN
                let alert = UIAlertController(title: "Invalid ISBN", message: "Please double check your ISBN format. We recommend using the scanner.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                // disable upload button
                self.uploadButton.isEnabled = false
                
                // bail out
                self.activityIndicator.stopAnimating()
                return
            } else if ((response.response?.statusCode)! == 401) {
                self.activityIndicator.stopAnimating()
                // present login screen on 401
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
                vc.explainString = "There was a problem with your account.\nPlease logout, log back in, and re-try your previous action."
                self.present(vc, animated: true, completion: nil)
                return
            } else {
                print((response.response?.statusCode)!)
                let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, please try again later. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
                return
            }
            
            
            // Grab and display publication info
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                
                // Grab publication ID for listing
                self.publication_id = JSON["id"] as? Int
                
                // Check for empty strings, display alternatives
                let titleString = JSON["title"] as? String
                let authorString = JSON["author"] as? String
                let yearString = JSON["year"] as? String
                let editionString = JSON["edition"] as? String
                
                // Display publication info
                self.titleLabel.text = titleString != "" && titleString != nil ? titleString: "No title info"
                self.authorLabel.text = authorString != "" && authorString != nil ? authorString : "No author info"
                self.yearLabel.text = yearString != "" && yearString != nil ? yearString : "No year info"
                self.editionLabel.text = editionString != "" && editionString != nil ? editionString : "No edition info"
                // Get image using URL - App Transport allows for Google Books specifically right now
                if let url  = NSURL(string: (JSON["image"] as? String)!),
                    let data = NSData(contentsOf: url as URL)
                {
                    self.bookImage.image = UIImage(data: data as Data)
                } else {
                    self.bookImage.image = #imageLiteral(resourceName: "bb_logo_1024")
                }
                
                // get current course information
                if let currentPublicationCourses = JSON["courses"] as? Array<String> {
                    self.courses = self.courses + (currentPublicationCourses)
                    var allCoursesString = ""
                    for i in 0..<currentPublicationCourses.count {
                        allCoursesString = allCoursesString + currentPublicationCourses[i]
                        if (i < currentPublicationCourses.count - 1) {
                            allCoursesString = allCoursesString + ", "
                        }
                    }
                    self.coursesLabel.text = allCoursesString
                }
            }
            
            self.activityIndicator.stopAnimating()
        }
        
    }

}
