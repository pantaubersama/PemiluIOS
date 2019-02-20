//
//  SectionViewCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class SectionViewCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var titleIv: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SectionViewCell: IReusableCell {
    
    struct Input {
        let title : String
        let type : ItemType
    }
    
    func configureCell(item: Input) {
        titleLbl.text = item.title
        
        switch item.type {
        case .done:
            titleIv.image = UIImage(named: "icDebatDone")
        case .challenge:
            titleIv.image = UIImage(named: "icChallenge")
        default: break
            
        }
    }
}
