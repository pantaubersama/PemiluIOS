//
//  WordstadiumCollectionCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class WordstadiumCollectionCell: UICollectionViewCell {

    @IBOutlet weak var backgroundItem: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var moreMenuBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

extension WordstadiumCollectionCell: IReusableCell {
    
    struct Input {
        let type : ItemType
    }
    
    func configureCell(item: Input) {
        switch item.type {
        case .live:
            backgroundItem.image = UIImage(named: "bgWordstadiumLive")
            titleLbl.text = "Live Now"
        case .inProgress:
            backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
            titleLbl.text = "Open Challenge"
        default: break
        }
    }
}
