//
//  ScanViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/1/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import MTBBarcodeScanner
import FBSDKCoreKit
import FBSDKShareKit
import Alamofire

class ScanViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var manualISBNfield: UITextField!
    @IBOutlet weak var scanISBNPreview: UIImageView!
    @IBOutlet weak var lookupISBNButton: UIButton!
    @IBOutlet weak var lightingTipLabel: UILabel!
    
    
    var scanISBN: String?
    var scanner: MTBBarcodeScanner?
    var deviceRegistered = false
    
    // check if user is logged in or not already
    override func viewDidAppear(_ animated: Bool) {
        
        let prefs = UserDefaults.standard
        if let _ = prefs.string(forKey: "email"), let _ = prefs.string(forKey: "rails_token"),  let _ = prefs.string(forKey: "fb_uid") {
            
            // don't re-register the device in the same session
            if deviceRegistered {
                return
            }
            
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
                if (response.result.error == nil) && ((response.response?.statusCode)! == 200) {
                    print("**SUCCESSFUL DEVICE REGISTRATION**")
                    self.deviceRegistered = true
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
        } else {
            // present loginview if not
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginView")
            self.present(vc, animated: true, completion: nil)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanner = MTBBarcodeScanner(previewView: scanISBNPreview)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.stopScanner), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.stopScanner), name:NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.stopScanner), name:NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        // listen for events on this field
        self.manualISBNfield.delegate = self

    }
    
    // when view shows up make sure API button is properly enabled
    override func viewWillAppear(_ animated: Bool) {
        if self.manualISBNfield.text == "" {
           self.lookupISBNButton.isEnabled = false
        } else {
           self.lookupISBNButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // close scanner when leaving view
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        stopScanner()
    }
    
    // check for if something was added to the text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.manualISBNfield.text != "" {
            self.lookupISBNButton.isEnabled = true
        } else {
            self.lookupISBNButton.isEnabled = false
        }
    }
    
    
    // Dismiss KB  - touch outside the field after editing has started
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.manualISBNfield.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! UploadViewController
        destinationVC.isbn = manualISBNfield.text!
        
        // close scanner when advancing
        stopScanner()
    }
    
    // MARK: - Actions
    @IBAction func startISBNScan(_ sender: UIButton) {
        self.lightingTipLabel.text = "The scanner works MUCH better with good lighting."
        self.scanner?.startScanning(resultBlock: { codes in
            let codeObjects = codes as! [AVMetadataMachineReadableCodeObject]?
            for code in codeObjects! {
                let stringValue = code.stringValue!
                if stringValue.characters.count == 13 {
                    self.stopScanner()
                    self.scanISBN = stringValue
                    self.manualISBNfield.text = stringValue
                    self.lookupISBNButton.isEnabled = true
                }
            }
            
        }, error: nil)
    }
    
    // custom version of pod's stop scanning 
    // checks for scanner scanning and removes help text on lighting
    func stopScanner() {
        self.lightingTipLabel.text = ""
        if (self.scanner?.isScanning())! {
            self.scanner?.stopScanning()
        }
    }

}
