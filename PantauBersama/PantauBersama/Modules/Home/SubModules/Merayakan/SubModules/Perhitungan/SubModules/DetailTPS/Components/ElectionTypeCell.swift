//
//  ElectionTypeCell.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 28/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class ElectionTypeCell: UITableViewCell, IReusableCell {
    @IBOutlet weak var lblTitle: Label!
    @IBOutlet weak var btnFirstOption: Button!
    @IBOutlet weak var btnSecOption: Button!
    
    func configureCell(item: ElectionType) {
        lblTitle.text = item.title
        btnFirstOption.setImage(item.imgFirstOption, for: .normal)
        btnSecOption.setImage(item.imgSecOption, for: .normal)
    }
}
