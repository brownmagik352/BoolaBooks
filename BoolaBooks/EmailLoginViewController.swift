//
//  EmailLoginViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/17/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import Alamofire

class EmailLoginViewController: UIViewController, UITextFieldDelegate {

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

        self.signUpButton.isEnabled = false
        self.passwordSignUpField.delegate = self
        self.confirmPasswordSignUpField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - KB manipulation 
    
    // Dismiss KB  - touch outside the field after editing has started
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.emailLoginField.resignFirstResponder()
        self.passwordLoginField.resignFirstResponder()
        self.nameSignUpField.resignFirstResponder()
        self.emailSignUpField.resignFirstResponder()
        self.passwordSignUpField.resignFirstResponder()
        self.confirmPasswordSignUpField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    // check if password and confirm password are same and over 8 chars
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.passwordSignUpField.text != "" && self.confirmPasswordSignUpField.text != "" {
            if self.passwordSignUpField.text! == self.confirmPasswordSignUpField.text! && self.passwordSignUpField.text!.characters.count >= 8 {
                self.signUpButton.isEnabled = true
            }
        }
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
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        register()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        login()
    }
    
    
    
    // Register User with Email
    func register() {
        
        // Notes not supported in MVP
        let parameters: Parameters = [
            "user": [
                "name": nameSignUpField.text,
                "email": emailSignUpField.text,
                "password": passwordSignUpField.text
            ]
        ]
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/auth/", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            if (response.result.error == nil) && (response.response?.statusCode == 201) {
                print("**SUCCESSFUL EMAIL REGISTRATION**")
            } else if ((response.response?.statusCode)! == 422) {
                let alert = UIAlertController(title: "Your Sign Up is Bad", message: "Please double-check your sign-up info. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            } else {
                let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, please try again later. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                
                // save login info
                let prefs = UserDefaults.standard
                prefs.setValue(JSON["email"]!, forKey: "email")
                prefs.setValue(JSON["authentication_token"]!, forKey: "rails_token")
                prefs.setValue(JSON["uid"]!, forKey: "uid")
                
                // redirect back to SCAN (or stay until login view is used)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

            }
        }
        
    }
    
    // login with email
    func login() {
        
        // Notes not supported in MVP
        let parameters: Parameters = [
            "email": emailLoginField.text!,
            "password": passwordLoginField.text!    
        ]
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/auth/sign_in", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            if (response.result.error == nil) && (response.response?.statusCode == 200) {
                print("**SUCCESSFUL EMAIL LOGIN**")
            } else if ((response.response?.statusCode)! == 401) {
                let alert = UIAlertController(title: "Incorrect login info.", message: "Please double-check your login info. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            } else {
                let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, please try again later. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                
                // save login info
                let prefs = UserDefaults.standard
                prefs.setValue(JSON["email"]!, forKey: "email")
                prefs.setValue(JSON["authentication_token"]!, forKey: "rails_token")
                prefs.setValue(JSON["uid"]!, forKey: "uid")
                
                // redirect back to SCAN
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                
            }
        }
        
    }

}
