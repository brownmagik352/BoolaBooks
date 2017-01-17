//
//  SeeNotesViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/16/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit

class SeeNotesViewController: UIViewController {

    @IBOutlet weak var notesLabel: UILabel!
    var notesString = "No Notes for this Book"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.notesLabel.text = self.notesString
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
