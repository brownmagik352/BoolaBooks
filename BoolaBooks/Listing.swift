//
//  File.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/1/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit

class Listing {

    var publication_id: Int?
    
    var condition: String?
    var buyable: Bool?
    var price: Float?
    var notes: String? // not supported in MVP
    var course: String? // still unclear where this is being kept, route does not support it 1/2/17
}
