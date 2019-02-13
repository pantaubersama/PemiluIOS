//
//  ArgumentRightCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class ArgumentRightCell: UITableViewCell, IReusableCell {
    @IBOutlet weak var lbArgument: Label!
    @IBOutlet weak var lbCreatedAt: Label!
    @IBOutlet weak var lbReadEstimation: Label!
    @IBOutlet weak var btnClap: ImageButton!
    @IBOutlet weak var lbClapCount: Label!
    @IBOutlet weak var lbClapStatus: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
