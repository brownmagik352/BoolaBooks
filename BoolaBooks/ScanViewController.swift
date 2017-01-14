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

class ScanViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var manualISBNfield: UITextField!
    @IBOutlet weak var scanISBNPreview: UIImageView!
    var scanISBN: String?
    var scanner: MTBBarcodeScanner?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanner = MTBBarcodeScanner(previewView: scanISBNPreview)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.stopScanner), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.stopScanner), name:NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.stopScanner), name:NSNotification.Name.UIApplicationWillResignActive, object: nil)

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
    
    // Dismiss KB  - touch outside the field after editing has started
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        manualISBNfield.resignFirstResponder()
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
