//
//  ScanViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/1/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import Alamofire

class ScanViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var manualISBNfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    @IBAction func manualISBNlookup(_ sender: UIButton) {
        let parameters: Parameters = ["isbn": manualISBNfield.text! ]
        
        let prefs = UserDefaults.standard
        let headers: HTTPHeaders = [
            "X-User-Email": prefs.string(forKey: "email")!,
            "X-User-Token": prefs.string(forKey: "rails_token")!,
            "Content-type": "application/json",
            "Accept": "application/json"
        ]

        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/publications/isbn", parameters: parameters, headers: headers).responseJSON { response in
            debugPrint(response)
        }
    }
    

}
