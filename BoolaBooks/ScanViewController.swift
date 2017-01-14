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

class ScanViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var manualISBNfield: UITextField!
    @IBOutlet weak var scanISBNPreview: UIImageView!
    @IBOutlet weak var lookupISBNButton: UIButton!
    var scanISBN: String?
    var scanner: MTBBarcodeScanner?

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
        self.scanner?.startScanning(resultBlock: { codes in
            let codeObjects = codes as! [AVMetadataMachineReadableCodeObject]?
            for code in codeObjects! {
                let stringValue = code.stringValue!
                if stringValue.characters.count == 13 {
                    self.scanner?.stopScanning()
                    self.scanISBN = stringValue
                    self.manualISBNfield.text = stringValue
                    self.lookupISBNButton.isEnabled = true
                }
            }
            
        }, error: nil)
    }
    
    func stopScanner() {
        if (self.scanner?.isScanning())! {
            self.scanner?.stopScanning()
        }
    }

}
