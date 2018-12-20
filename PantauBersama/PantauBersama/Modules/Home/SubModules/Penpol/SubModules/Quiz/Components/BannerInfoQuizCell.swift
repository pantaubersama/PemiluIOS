//
//  BannerInfoQuizCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common

class BannerInfoQuizCell: UITableViewCell, IReusableCell {
    @IBOutlet weak var ivInfo: UIImageView!
    @IBOutlet weak var lbReadMore: Label!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
