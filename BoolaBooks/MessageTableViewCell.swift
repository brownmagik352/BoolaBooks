//
//  MessageTableViewCell.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/10/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    // Mark: - Properties
    @IBOutlet weak var senderImage: UIImageView!
    @IBOutlet weak var messageWordsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
