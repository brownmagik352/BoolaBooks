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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getConversations()
        self.tableView.contentInset = UIEdgeInsetsMake(25, 0, 0, 0)    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
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
        
        
        // Populate the labels in the table cell
        cell.titleLabel.text = publication["title"] as? String
        cell.courseLabel.text = courses.count > 0 ? courses[0] : "No Course Info Available" // needs to show all courses actually
        cell.priceLabel.text = "$\(listing["price"]!)"
        cell.conditionLabel.text = listing["condition"] as? String
        cell.buyableLabel.text = "\(listing["buyable"]!)"
        //        // Get image using URL - App Transport allows for Google Books specifically right now
        if let url  = NSURL(string: (publication["image"] as? String)!),
            let data = NSData(contentsOf: url as URL)
        {
            cell.photoView.image = UIImage(data: data as Data)
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
        
        guard let chatDetailViewController = segue.destination as? ChatDetailViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedChatCell = sender as? ChatTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedChatCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let chat: Dictionary <String, Any> = indexPath.section == 0 ? sellChats[indexPath.row] : buyChats[indexPath.row]
        chatDetailViewController.conversationID = chat["id"] as! Int

    }
 
    
    // MARK: - BoolaBooks API Calls
    
    // Find all listings for a given search
    func getConversations() {
        
        let prefs = UserDefaults.standard
        let headers: HTTPHeaders = [
            "X-User-Email": prefs.string(forKey: "email")!,
            "X-User-Token": prefs.string(forKey: "rails_token")!,
            "Content-type": "application/json",
            "Accept": "application/json"
        ]
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/conversations", headers: headers).responseJSON { response in
            
            if (response.result.error == nil) {
                print("**SUCCESSFUL CHATS LOOKUP**")
            }

            // parse search results from JSON
            if let data = response.data {
                let json = JSON(data: data)
                
                // parse all selling chats
                for i in 0..<json["selling"].arrayObject!.count {
                    self.sellChats.append(json["selling"].arrayObject?[i] as! Dictionary<String, Any>)
                }
                
                // parse all buying chats
                for i in 0..<json["buying"].arrayObject!.count {
                    self.buyChats.append(json["buying"].arrayObject?[i] as! Dictionary<String, Any>)
                }
                
                // need this so that once new data is in table can pull it out
                self.tableView.reloadData()
            }
        }
    }


}
