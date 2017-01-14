//
//  AboutViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/12/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    

    @IBOutlet weak var mainLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        var finalString = ""
        finalString = finalString + "Contact Information: contact@boolabooks.com.\n\n"
        finalString = finalString + "BoolaBooks was created by \nApurv Suman (PC '16) and Aaron Shim (SY '16).\n\n"
        finalString = finalString + "Copyright 2016 Apurv Suman.\n\n"
        finalString = finalString + "Contributors: Timur Guler (Marketing), Megan Valentine (Design), Kevin Fung (BoolaMarket co-founder).\n\n"
        finalString = finalString + "This application uses Open Source components. You can find the source code of their open source projects along with license information below. We acknowledge and are grateful to these developers for their contributions to open source.\n\n"
        finalString = finalString + "Alamofire: https://github.com/Alamofire/Alamofire, MIT License.\n\n"
        finalString = finalString + "SwiftyJSON: https://github.com/SwiftyJSON/SwiftyJSON, MIT License.\n\n"
        finalString = finalString + "SwiftWebSocket: https://github.com/tidwall/SwiftWebSocket, MIT License.\n\n"
        finalString = finalString + "MTBBarcodeScanner: https://github.com/mikebuss/MTBBarcodeScanner, MIT License.\n\n"
        finalString = finalString + "Book images and information is provided courtesy of Google Books and Amazon Web Services Product Advertising. Course information obtained from http://catalog.yale.edu/ycps/subjects-of-instruction/."

        
        mainLabel.text = finalString
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
