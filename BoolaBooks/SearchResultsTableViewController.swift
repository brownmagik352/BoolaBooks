//
//  SearchResultsTableViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/2/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchResultsTableViewController: UITableViewController {
    
    
    
    // MARK: - Properties
    var searchQuery: String?
    var listings: [[String:Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        search()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ListingTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ListingTableViewCell
        
        // for now, pullinng listing and its publication info
        let listing = listings[indexPath.row]
        let publication = listing["publication"] as! Dictionary<String, Any>
        let courses: Array<String> = publication["courses"] as! Array<String>
        
        
        // Populate the labels in the table cell
        cell.titleLabel.text = publication["title"] as? String
        if courses.count > 0 {
            cell.courseLabel.text = courses[0]
        } else {
            cell.courseLabel.text = "No Course Info Available"
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - BoolaBooks API Calls
    
    // Using BoolaBooks API to find all listings for a given search
    func search() {
        
        let prefs = UserDefaults.standard
        let headers: HTTPHeaders = [
            "X-User-Email": prefs.string(forKey: "email")!,
            "X-User-Token": prefs.string(forKey: "rails_token")!,
            "Content-type": "application/json",
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = ["query": searchQuery!, "num_items": 20 ]
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/search", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in

            if (response.result.error == nil) {
                print("**SUCCESSFUL SEARCH**")
            }
            
            debugPrint(response)
            
            // parse search results from JSON
            if let data = response.data {
                let json = JSON(data: data)
//                print(json)
                // avoid null at end
                for i in 0..<json.arrayObject!.count {
                    self.listings.append(json.arrayObject?[i] as! Dictionary<String, Any>)
                }
                self.tableView.reloadData() // need this so that once new data is in table can pull it out
            }
        }
    }
    
}
