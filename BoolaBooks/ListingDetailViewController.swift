//
//  ListingDetailViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/5/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import Alamofire

class ListingDetailViewController: UIViewController {
    
    // MARK: - Properties
    // Outlets
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var buyableLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var seeNotesButton: UIButton!
    
    // segue capture variables
    var photoImage: UIImage?
    var priceString: String?
    var conditionString: String?
    var buyableString: String?
    var courseString: String?
    var titleString: String?
    var authorString: String?
    var yearString: String?
    var editionString: String?
    var notesString: String?
    var listingID: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        photoView.image = photoImage
        priceLabel.text = "$" + priceString!
        conditionLabel.text = conditionString
        buyableLabel.text = buyableString
        courseLabel.text = courseString
        titleLabel.text = titleString
        authorLabel.text = authorString
        yearLabel.text = yearString
        editionLabel.text = editionString
        if self.notesString == "" {
            seeNotesButton.isEnabled = false
            seeNotesButton.setTitle("No notes for this book", for: .normal)
            seeNotesButton.setTitleColor(UIColor.gray, for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SeeNotesViewController
        destinationVC.notesString = self.notesString!
    }
 
    
    // MARK: - Actions
    
    @IBAction func startChat(_ sender: UIBarButtonItem) {
        
        let prefs = UserDefaults.standard
        let headers: HTTPHeaders = [
            "X-User-Email": prefs.string(forKey: "email")!,
            "X-User-Token": prefs.string(forKey: "rails_token")!,
            "Content-type": "application/json",
            "Accept": "application/json"
        ]
        
        let firstMessage = "Hi! I'm interested in buying your book."
        
        // Notes not supported in MVP
        let parameters: Parameters = [
            "listing_id": self.listingID!,
            "first_message": firstMessage
        ]
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/conversations/start", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if (response.result.error == nil) && response.response?.statusCode == 200 {
                print("**SUCCESSFUL CHAT START**")
                let alert = UIAlertController(title: "Chat Started", message: "You can now chat with the seller. Visit the Chat tab in the bottom right corner to get start.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if ((response.response?.statusCode)! == 401) {
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

}
