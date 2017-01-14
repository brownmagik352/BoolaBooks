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
    @IBOutlet weak var secondaryLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        var mainString = ""
        mainString = mainString + "Contact Information: contact@boolabooks.com\n\n"
        mainString = mainString + "BoolaBooks was created by:\nApurv Suman (Yale, PC '16)\nAaron Shim (Yale, SY '16)\n\n"
        
        var secondaryString = ""
        secondaryString = secondaryString + "Copyright 2016 Apurv Suman.\n\n"
        secondaryString = secondaryString + "Specal Thanks: Timur Guler (Marketing), Megan Valentine (Design), Kevin Fung (BoolaMarket co-founder).\n\n"
        secondaryString = secondaryString + "This application uses Open Source components. You can find the source code of their open source projects along with license information below. We acknowledge and are grateful to these developers for their contributions to open source.\n\n"
        secondaryString = secondaryString + "Alamofire: https://github.com/Alamofire/Alamofire, MIT License.\n\n"
        secondaryString = secondaryString + "SwiftyJSON: https://github.com/SwiftyJSON/SwiftyJSON, MIT License.\n\n"
        secondaryString = secondaryString + "SwiftWebSocket: https://github.com/tidwall/SwiftWebSocket, MIT License.\n\n"
        secondaryString = secondaryString + "MTBBarcodeScanner: https://github.com/mikebuss/MTBBarcodeScanner, MIT License.\n\n"
        secondaryString = secondaryString + "Book images and information are provided courtesy of Google Books and Amazon Web Services Product Advertising. Course information obtained from http://catalog.yale.edu/ycps/subjects-of-instruction/."

        
        mainLabel.text = mainString
        secondaryLabel.text = secondaryString
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
