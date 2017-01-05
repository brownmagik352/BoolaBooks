//
//  ListingTableViewCell.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/2/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit

class ListingTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var buyableLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
