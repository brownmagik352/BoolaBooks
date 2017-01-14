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
            
            // register device for notifications
            let headers: HTTPHeaders = [
                "X-User-Email": prefs.string(forKey: "email")!,
                "X-User-Token": prefs.string(forKey: "rails_token")!,
                "Content-type": "application/json",
                "Accept": "application/json"
            ]
            
            let parameters: Parameters = [
                "apn_token": prefs.string(forKey: "device_token")!
            ]
            
            Alamofire.request("https://boolabooks.herokuapp.com/api/v1/register_ios", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if (response.result.error == nil) && ((response.response?.statusCode)! == 200){
                    print("**SUCCESSFUL DEVICE REGISTRATION**")
                } else if ((response.response?.statusCode)! == 401) {
                    print("401")
                    let alert = UIAlertController(title: "Login Failed", message: "We're sorry, please restart the app and try again. If that fails, please re-install the app (you won't lose any of your data). Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                } else {
                    print((response.response?.statusCode)!)
                    let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, but you're device is not enabled to receive notifications from BoolaBooks. Notify contact@boolabooks.com if you would like to.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            
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
        
        print("**SUCCESSFUL FB LOG IN**")
        
        // Use FB Token to Get User Info
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, email, picture"])
        graphRequest?.start(completionHandler: { [weak self] connection, result, error in
            if error != nil {
                print("error \(error)")
            } else {
                let fbResult = result as! Dictionary<String, AnyObject>
                
                // image has some nesting that we have to pull out first
                let fbPicTemp1 = fbResult["picture"] as? Dictionary<String, Any>
                let fbPicTemp2 = fbPicTemp1?["data"] as? Dictionary<String, Any>
                var fbPicURL = fbPicTemp2?["url"] as? String
                let fbPicSilo = fbPicTemp2?["is_silhouette"] as? Int
                
                if fbPicSilo == 0 {
                    fbPicURL = "" //no image for fb user
                }

                // USING FB INFO NOW LOG IN TO APP
                let parameters: Parameters = [
                    "user": [
                        "email": fbResult["email"] as? String,
                        "provider": "facebook",
                        "uid": fbResult["id"] as? String,
                        "name": fbResult["name"] as? String,
                        "image": fbPicURL,
                        "oauth_token": FBSDKAccessToken.current().tokenString
                    ]
                ]
                
                Alamofire.request("https://boolabooks.herokuapp.com/api/v1/auth/facebook", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    
                    if (response.result.error == nil) && (response.response?.statusCode)! == 200 {
                        print("**SUCCESSFUL AUTH**")
                    } else if ((response.response?.statusCode)! == 401) {
                        print("401")
                        let alert = UIAlertController(title: "Login Failed", message: "We're sorry, please restart the app and try again. If that fails, please re-install the app (you won't lose any of your data). Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                        return
                    } else {
                        print((response.response?.statusCode)!)
                        let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, please try again later. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    if let result = response.result.value {
                        let JSON = result as! NSDictionary

                        // save login info
                        let prefs = UserDefaults.standard
                        prefs.setValue(JSON["email"]!, forKey: "email")
                        prefs.setValue(JSON["authentication_token"]!, forKey: "rails_token")
                        prefs.setValue(JSON["uid"]!, forKey: "fb_uid")
                        
                        // register device for notifications
                        let headers: HTTPHeaders = [
                            "X-User-Email": prefs.string(forKey: "email")!,
                            "X-User-Token": prefs.string(forKey: "rails_token")!,
                            "Content-type": "application/json",
                            "Accept": "application/json"
                        ]
                        
                        let parameters: Parameters = [
                            "apn_token": prefs.string(forKey: "device_token")!
                        ]
                        
                        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/register_ios", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                            if (response.result.error == nil) && ((response.response?.statusCode)! == 200){
                                print("**SUCCESSFUL DEVICE REGISTRATION**")
                            } else if ((response.response?.statusCode)! == 401) {
                                print("401")
                                let alert = UIAlertController(title: "Login Failed", message: "We're sorry, please restart the app and try again. If that fails, please re-install the app (you won't lose any of your data). Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                                self?.present(alert, animated: true, completion: nil)
                                return
                            } else {
                                print((response.response?.statusCode)!)
                                let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, but you're device is not enabled to receive notifications from BoolaBooks. Notify contact@boolabooks.com if you would like to.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                                self?.present(alert, animated: true, completion: nil)
                                return
                            }
                        }
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
