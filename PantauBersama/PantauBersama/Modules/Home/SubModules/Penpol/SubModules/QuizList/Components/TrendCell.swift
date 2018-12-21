//
//  TrendCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common

class TrendCell: UITableViewCell, IReusableCell {
    @IBOutlet weak var ivPaslon: UIImageView!
    @IBOutlet weak var lbTotal: Label!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
