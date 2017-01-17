//
//  EmailLoginViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/17/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit

class EmailLoginViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var emailLoginField: UITextField!
    @IBOutlet weak var passwordLoginField: UITextField!
    @IBOutlet weak var nameSignUpField: UITextField!
    @IBOutlet weak var emailSignUpField: UITextField!
    @IBOutlet weak var passwordSignUpField: UITextField!
    @IBOutlet weak var confirmPasswordSignUpField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
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
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
