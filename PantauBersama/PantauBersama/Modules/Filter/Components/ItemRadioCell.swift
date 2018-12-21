//
//  ItemRadioCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common

class ItemRadioCell: UITableViewCell, IReusableCell {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var titleLabel: Label!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    struct Input {
        let data: FilterField
    }
    
    func configureCell(item: Input) {
        titleLabel.text = item.data.key
        
    }
}
