//
//  SectionViewCell2.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking

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
        let type: ProgressType
    }
    
    func configureCell(item: Input) {
        switch item.type {
        case .liveNow:
            titleLbl.text = "LINIMASA DEBAT"
            descriptionLbl.text = "Daftar challenge dan debat yang akan atau sudah berlangsung ditampilkan semua di sini."
        case .inProgress:
            titleLbl.text = "MY WORDSTADIUM"
            descriptionLbl.text = "Daftar tantangan dan debat yang akan atau sudah kamu ikuti ditampilkan semua di sini."
        default:
            break
        }

    
    }
}
