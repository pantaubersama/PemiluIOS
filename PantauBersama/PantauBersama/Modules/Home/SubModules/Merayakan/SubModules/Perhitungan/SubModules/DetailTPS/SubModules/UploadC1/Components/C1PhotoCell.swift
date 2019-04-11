//
//  C1PhotoCell.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 04/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class C1PhotoCell: UITableViewCell {

    @IBOutlet weak var ivImages: UIImageView!
    @IBOutlet weak var lblTitle: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension C1PhotoCell: IReusableCell {
    
    struct Input {
        let data: StashImages
        let title: String
    }
    
    func configureCell(item: Input) {
        ivImages.image = item.data.images
        lblTitle.text = "Gambar " + item.title
    }
    
}
