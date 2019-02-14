//
//  WordstadiumCollectionCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common


enum ItemCollectionType {
    case live
    case challenge
}

class WordstadiumCollectionCell: UICollectionViewCell {

    @IBOutlet weak var backgroundItem: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

extension WordstadiumCollectionCell: IReusableCell {
    
    struct Input {
        let type : ItemCollectionType
    }
    
    func configureCell(item: Input) {
        switch item.type {
        case .live:
            backgroundItem.image = UIImage(named: "bgWordstadiumLive")
        case .challenge:
            backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
        }
    }
}
