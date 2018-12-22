//
//  SectionCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common

class SectionCell: UITableViewCell, IReusableCell {
    
    @IBOutlet weak var sectionLabel: Label!
    @IBOutlet weak var buttonCell: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
