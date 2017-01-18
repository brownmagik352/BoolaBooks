//
//  ChatTableViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/6/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChatTableViewController: UITableViewController {
    
    // MARK: - Properties
    var sellChats: [[String:Any]] = [] // selling is going to go first (section #0) since the app is structured sell-first in general
    var buyChats: [[String:Any]] = []
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)  // spinner to show during loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.white
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.center = view.center
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        getConversations()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Akkurat-Bold", size: 18.0)
        header.textLabel?.frame = header.frame
//        header.textLabel?.textAlignment = .center
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Selling"
        } else {
            return "Buying"
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sellChats.count
        } else {
            return buyChats.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "ChatTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ChatTableViewCell
        
        // pull necessary nested info, use chat -> listing -> publication -> courses
        let chat = indexPath.section == 0 ? sellChats[indexPath.row] : buyChats[indexPath.row] 
        let listing = chat["listing"] as! Dictionary<String, Any>
        let publication = listing["publication"] as! Dictionary<String, Any>
        let courses: Array<String> = publication["courses"] as! Array<String>
        var allCoursesString = "" //at worst it will be empty string
        for i in 0..<courses.count {
            allCoursesString = allCoursesString + courses[i]
            if (i < courses.count - 1) {
                allCoursesString = allCoursesString + ", "
            }
        }
        
        let unreadCount = indexPath.section == 0 ? chat["num_unread_by_seller"] as? Int : chat["num_unread_by_buyer"] as? Int 
        let unread = (unreadCount ?? 0) > 0 ? "(*) " : ""
        
        // Populate the labels in the table cell
        cell.titleLabel.text = unread + (publication["title"] as? String ?? "No title info")
        cell.courseLabel.text = allCoursesString != "" ? allCoursesString : "No course info" // at worst is empty string see declaration
        cell.priceLabel.text = "$" + String(format: "%.2f", (listing["price"] as? NSString ?? "").doubleValue)
        cell.conditionLabel.text = listing["condition"] as? String ?? "No condition info"
        cell.buyableLabel.text = (listing["buyable"] as? Bool ?? true) ? "Buy" : "Rent"
        cell.soldlabel.text = (listing["sold_at"] as? String) != nil ? "SOLD" : ""
        // Get image using URL - App Transport allows for Google Books specifically right now
        if let url  = NSURL(string: (publication["image"] as? String ?? "")),
            let data = NSData(contentsOf: url as URL)
        {
            cell.photoView.image = UIImage(data: data as Data)
        } else {
            cell.photoView.image = #imageLiteral(resourceName: "bb_logo_1024")
        }
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Figure out which cell/chat was selected
        guard let chatDetailViewController = segue.destination as? ChatDetailViewController else {
//            fatalError("Unexpected destination: \(segue.destination)")
            return
        }
        
        guard let selectedChatCell = sender as? ChatTableViewCell else {
//            fatalError("Unexpected sender: \(sender)")
            return
        }
        
        guard let indexPath = tableView.indexPath(for: selectedChatCell) else {
//            fatalError("The selected cell is not being displayed by the table")
            return
        }
        
        // Send ConversationID for selected Chat
        let chat: Dictionary<String, Any> = indexPath.section == 0 ? sellChats[indexPath.row] : buyChats[indexPath.row]
        chatDetailViewController.conversationID = chat["id"] as? Int
        
        // Send Listing for selected Chat (need for Marking Item as Sold and providing context about chat)
        let listing = chat["listing"] as! Dictionary<String, Any>
        chatDetailViewController.listingID = listing["id"] as? Int
        
        // Has listing been sold already or not?
        let soldAt = listing["sold_at"] as? String
        chatDetailViewController.sold = soldAt != nil
        
        // Send existing chat messages & images for selected Chat
        // needed for image data
        let seller = chat["seller"] as! Dictionary<String,Any>
        let sellerID = seller["id"] as? Int
        let sellerPhoto = "\(seller["image"] ?? "")"
        let sellerName = seller["name"] as? String ?? ""
        
        let buyer = chat["buyer"] as! Dictionary<String,Any>
//        let buyerID = buyer["id"] as? Int
        let buyerPhoto = "\(buyer["image"] ?? "")"
        let buyerName = buyer["name"] as? String ?? ""
        
        let messagesMeta = chat["messages"] as! Array<Dictionary<String, Any>>
        var messages: [String] = [] // actual text of each message
        var imageStrings: [String] = [] // image of messege sender
        var names: [String] = [] // name of message sender
        for i in 0..<messagesMeta.count {
            messages.append("\(messagesMeta[i]["text"] ?? "")")
            if messagesMeta[i]["sender_id"] as? Int ?? -1 == sellerID {
                imageStrings.append(sellerPhoto)
                names.append(sellerName)
            } else {
                imageStrings.append(buyerPhoto)
                names.append(buyerName)
            }
        }
        chatDetailViewController.messages = messages
        chatDetailViewController.imageStrings = imageStrings
        chatDetailViewController.names = names
        
        // Update the App Icon Badge to reflect these messages now being read
        let messagesRead = indexPath.section == 0 ? chat["num_unread_by_seller"] as? Int : chat["num_unread_by_buyer"] as? Int
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - (messagesRead ?? 0)
        
    }
 
    
    // MARK: - BoolaBooks API Calls
    
    // Find all chats
    func getConversations() {
        
        let prefs = UserDefaults.standard
        let headers: HTTPHeaders = [
            "X-User-Email": prefs.string(forKey: "email") ?? "",
            "X-User-Token": prefs.string(forKey: "rails_token") ?? "",
            "Content-type": "application/json",
            "Accept": "application/json"
        ]
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/conversations", headers: headers).responseJSON { response in
            
            if (response.result.error == nil) && response.response?.statusCode == 200 {
                print("**SUCCESSFUL ALL CHATS LOOKUP**")
            } else if (response.response?.statusCode == 401) {
                self.activityIndicator.stopAnimating()
                // present login screen on 401
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
                vc.explainString = "There was a problem with your account.\nPlease log back in and re-try your previous action."
                self.present(vc, animated: true, completion: nil)
                return
            } else {
                print(response.response?.statusCode ?? 0)
                let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, please try again later. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
                return
            }
            
            // will collect the updated chat info (can't use class versions because tableView delegate methods need non-empty ones)
            var tempSellChats: [[String:Any]] = []
            var tempBuyChats: [[String:Any]] = []

            // parse search results from JSON
            if let data = response.data {
                let json = JSON(data: data)
                
                // parse all selling chats
                for i in 0..<(json["selling"].arrayObject?.count ?? 0) {
                    tempSellChats.append(json["selling"].arrayObject?[i] as! Dictionary<String, Any>)
                }
                
                // parse all buying chats
                for i in 0..<(json["buying"].arrayObject?.count ?? 0) {
                    tempBuyChats.append(json["buying"].arrayObject?[i] as! Dictionary<String, Any>)
                }
                
                // no chats currently
                if tempSellChats.count == 0 && tempBuyChats.count == 0 {
                    let alert = UIAlertController(title: "No Chats Started", message: "To start a chat, search for a book and contact the seller or upload a book and wait to be contacted.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            
                // need this so that once new data is in table can update to show it
                self.sellChats = tempSellChats
                self.buyChats = tempBuyChats
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }


}
