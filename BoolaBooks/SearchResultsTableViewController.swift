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
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)  // spinner to show during loading

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Spinner Code
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.white
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.center = view.center
        self.view.addSubview(self.activityIndicator)

        self.activityIndicator.startAnimating()
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
        
        // for now, pulling listing, publication, and course info (listing -> publication -> courses)
        let listing = listings[indexPath.row]
        let publication = listing["publication"] as! Dictionary<String, Any>
        let courses: Array<String> = publication["courses"] as! Array<String>
        
        
        // Populate the labels in the table cell
        cell.titleLabel.text = publication["title"] as? String
        cell.courseLabel.text = courses.count > 0 ? courses[0] : "No Course Info Available" // needs to show all courses actually
        cell.priceLabel.text = "$" + String(format: "%.2f", (listing["price"] as! NSString).doubleValue)
        cell.conditionLabel.text = listing["condition"] as? String
        cell.buyableLabel.text = (listing["buyable"] as? Bool)! ? "Buy" : "Rent"
//        // Get image using URL - App Transport allows for Google Books specifically right now
        if let url  = NSURL(string: (publication["image"] as? String)!),
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
        //using code from Apple guide for convenience
        
        guard let listingDetailViewController = segue.destination as? ListingDetailViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedListingCell = sender as? ListingTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedListingCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        // grab the necessary info about the selected listing
        let selectedListing = listings[indexPath.row]
        let selectedListingPublication = selectedListing["publication"] as! Dictionary<String, Any>
        let selectedListingCourses: Array<String> = selectedListingPublication["courses"] as! Array<String>

        // pass on the data in the segue, have to pass it to variables rather than the label directly
        if let url  = NSURL(string: (selectedListingPublication["image"] as? String)!),
            let data = NSData(contentsOf: url as URL)
        {
            listingDetailViewController.photoImage = UIImage(data: data as Data)
        } else {
            listingDetailViewController.photoImage = #imageLiteral(resourceName: "bb_logo_1024")
        }
        
        listingDetailViewController.priceString = String(format: "%.2f", (selectedListing["price"] as! NSString).doubleValue)
        listingDetailViewController.conditionString = selectedListing["condition"] as? String
        listingDetailViewController.buyableString = selectedListing["buyable"] as! Bool ? "Buy" : "Rent"
        listingDetailViewController.courseString = selectedListingCourses.count > 0 ? selectedListingCourses[0] : "No Course Info Available" // needs to show all courses actually
        listingDetailViewController.titleString = selectedListingPublication["title"] as? String
        listingDetailViewController.authorString = selectedListingPublication["author"] as? String
        listingDetailViewController.yearString = selectedListingPublication["year"] as? String
        listingDetailViewController.editionString = selectedListingPublication["edition"] as? String
        listingDetailViewController.listingID = selectedListing["id"] as? Int
    }
    
    
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
        
        let parameters: Parameters = ["query": searchQuery!, "num_items": 90 ] //totally arbitrary, Aaron's can only support up to 100
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/search", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in

            if (response.result.error == nil) && (response.response?.statusCode == 200) {
                print("**SUCCESSFUL SEARCH**")
            } else if ((response.response?.statusCode)! == 401) {
                print("401")
                // force re-login
                self.activityIndicator.stopAnimating()
                return
            } else {
                print((response.response?.statusCode)!)
                let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, please try again later. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
                return
            }
            
            // parse search results from JSON
            if let data = response.data {
                let json = JSON(data: data)
                // avoid null at end
                for i in 0..<json.arrayObject!.count {
                    let listing = json.arrayObject?[i] as! Dictionary<String, Any>
                    // only show items that haven't been sold
                    let soldAt = listing["sold_at"] as? String
                    if soldAt == nil {
                        self.listings.append(listing)
                    }
                }
                
                if self.listings.count == 0 {
                    let alert = UIAlertController(title: "All Sold Out!", message: "Check back periodically, books get sold fast!\n\n Also, make sure there are no typos in your search terms.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                }
                self.tableView.reloadData() // need this so that once new data is in table can pull it out
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
}
