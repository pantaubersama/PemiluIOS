//
//  SectionViewCell2.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class SectionViewCell2: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SectionViewCell2: IReusableCell {
    struct Input {
        let title : String
        let desc : String
    }
    
    func configureCell(item: Input) {
        titleLbl.text = item.title
        descriptionLbl.text = item.desc
    
    }
}
