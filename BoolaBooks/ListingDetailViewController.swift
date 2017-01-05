//
//  ListingDetailViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/5/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit

class ListingDetailViewController: UIViewController {
    
    // MARK: - Properties
    // Outlets
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var buyableLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    
    // segue capture variables
    var photoImage: UIImage?
    var priceString: String?
    var conditionString: String?
    var buyableString: String?
    var courseString: String?
    var titleString: String?
    var authorString: String?
    var yearString: String?
    var editionString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        photoView.image = photoImage
        priceLabel.text = priceString
        conditionLabel.text = conditionString
        buyableLabel.text = buyableString
        courseLabel.text = courseString
        titleLabel.text = titleString
        authorLabel.text = authorString
        yearLabel.text = yearString
        editionLabel.text = editionString
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
