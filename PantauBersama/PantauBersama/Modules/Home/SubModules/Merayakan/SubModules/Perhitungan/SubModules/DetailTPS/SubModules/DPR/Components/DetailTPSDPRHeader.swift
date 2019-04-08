//
//  DetailTPSDPRHeader.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class DetailTPSDPRHeader: UIView {

    @IBOutlet weak var lblNameDapil: Label!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func configure(name: String) {
        lblNameDapil.text = "Dapil: " + name
    }

}
