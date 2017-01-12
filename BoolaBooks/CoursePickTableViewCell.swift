//
//  CoursePickTableViewCell.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/11/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit

class CoursePickTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var courseNumberLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
