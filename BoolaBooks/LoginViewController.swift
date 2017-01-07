//
//  LoginViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 12/28/16.
//  Copyright © 2016 Apurv Suman. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Alamofire

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    // needed to move past initial login screen if already authenticated
    override func viewDidAppear(_ animated: Bool) {
        
        let prefs = UserDefaults.standard
        if let _ = prefs.string(forKey: "email"), let _ = prefs.string(forKey: "rails_token"),  let _ = prefs.string(forKey: "fb_uid") {
            // ADVANCE TO NEXT SCREEN IF APP TOKEN EXISTS (USER IS ALREADY LOGGED IN)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "tabView")
            self.present(vc, animated: true, completion: nil)

        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton();
        loginButton.readPermissions = ["public_profile", "email"]
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        loginButton.delegate = self
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("LOGGED OUT")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        
        print("**SUCCESSFUL LOG IN**")
        
        // Use FB Token to Get User Info
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, email, picture"])
        graphRequest?.start(completionHandler: { [weak self] connection, result, error in
            if error != nil {
                print("error \(error)")
            } else {
                let fbResult = result as! Dictionary<String, AnyObject>
                // USING FB INFO NOW LOG IN TO APP
                let parameters: Parameters = [
                    "user": [
                        "email": fbResult["email"] as? String,
                        "provider": "facebook",
                        "uid": fbResult["id"] as? String,
                        "name": fbResult["name"] as? String,
                        "image": fbResult["picture"] as? String,
                        "oauth_token": FBSDKAccessToken.current().tokenString
                    ]
                ]
                
                Alamofire.request("https://boolabooks.herokuapp.com/api/v1/auth/facebook", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in

                    if let result = response.result.value {
                        let JSON = result as! NSDictionary

                        // save login info
                        let prefs = UserDefaults.standard
                        prefs.setValue(JSON["email"]!, forKey: "email")
                        prefs.setValue(JSON["authentication_token"]!, forKey: "rails_token")
                        prefs.setValue(JSON["uid"]!, forKey: "fb_uid")
                    }
                    
                }
                
                // ADVANCE TO NEXT SCREEN AFTER LOGIN
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "tabView")
                self?.present(vc, animated: true, completion: nil)
                
            }
        })
    
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

}
