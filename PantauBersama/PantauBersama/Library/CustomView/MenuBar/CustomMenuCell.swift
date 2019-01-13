//
//  SearchTabCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 13/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class CustomMenuCell: UICollectionViewCell {
    static let identifier: String = "CustomMenuCell"
    static let nib: UINib = UINib(nibName: "CustomMenuCell", bundle: nil)
    @IBOutlet weak var lbTitle: Label!
    @IBOutlet weak var viewSelectedIndicator: UIView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                lbTitle.typeLabel = "bold"
                lbTitle.textColor = .white
                viewSelectedIndicator.isHidden = false
            } else {
                lbTitle.typeLabel = "normal"
                lbTitle.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5052816901)
                viewSelectedIndicator.isHidden = true
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureItem(item: MenuItem) {
        lbTitle.text = item.title
    }
}
