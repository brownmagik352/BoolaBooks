//
//  CoursePickTableViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/11/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// need this to send back data back from modal
// source: http://stackoverflow.com/questions/28502653/passing-data-from-modal-segue-to-parent
protocol ModalViewControllerDelegate {
    func sendModalValue1(value: String) // sending courses back
    func sendModalValue2(value: String) // sending notes back
}

class CoursePickTableViewController: UITableViewController {
    
    // MARK: - Properties
    var courses: Array<String> = []
    var delegate: ModalViewControllerDelegate! // need this to send back data back from modal, guaranteed by upload VC's prepare segue
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)  // spinner to show during loading

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Spinner Code
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.white
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.center = view.center
        self.view.addSubview(self.activityIndicator)
        
        self.tableView.contentInset = UIEdgeInsetsMake(25, 0, 0, 0)
        
        self.activityIndicator.startAnimating()
        getAllCourses()
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
        return courses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoursePickTableViewCell", for: indexPath) as! CoursePickTableViewCell

        let courseNumber = courses[indexPath.row]
        
        cell.courseNumberLabel.text = courseNumber
        cell.addButton.setTitle("+", for: .normal)

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
    
    // MARK: - Actions
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        // get cell & course number
        let cell = sender.superview?.superview as! CoursePickTableViewCell
        let courseNumber = cell.courseNumberLabel.text! //guaranteed based on how table cells are drawn
        
        // sending only one course back
        self.delegate.sendModalValue1(value: courseNumber)
        dismiss(animated: true, completion: nil)
        
    }
    
    
    // MARK: - BoolaBooks API Calls
    func getAllCourses() {
        let prefs = UserDefaults.standard
        let headers: HTTPHeaders = [
            "X-User-Email": prefs.string(forKey: "email") ?? "",
            "X-User-Token": prefs.string(forKey: "rails_token") ?? "",
            "Content-type": "application/json",
            "Accept": "application/json"
        ]
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/courses", headers: headers).responseJSON { response in
            
            if (response.result.error == nil) && response.response?.statusCode == 200 {
                print("**SUCCESSFUL ALL COURSES LOOKUP**")
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
            
            if let result = response.result.value {
                let JSON = result as! NSArray
                
                for i in 0..<JSON.count {
                    var tempCourseDict = JSON[i] as! Dictionary<String, Any>
                    if let courseNum = tempCourseDict["number"] as? String {
                        self.courses.append(courseNum)
                    }
                }
                
                self.tableView.reloadData() // update after API call
                self.activityIndicator.stopAnimating()
            }
        }
    }

}
