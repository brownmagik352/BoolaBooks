//
//  ScanViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/1/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import MTBBarcodeScanner

class ScanViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var manualISBNfield: UITextField!
    @IBOutlet weak var scanISBNPreview: UIImageView!
    var scanISBN: String?
    var scanner: MTBBarcodeScanner?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanner = MTBBarcodeScanner(previewView: scanISBNPreview)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! UploadViewController
        destinationVC.isbn = manualISBNfield.text!
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

}
