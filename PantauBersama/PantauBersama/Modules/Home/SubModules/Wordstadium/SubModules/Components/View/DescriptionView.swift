//
//  DescriptionView.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class DescriptionView: UIView {
    @IBOutlet weak var descriptionLbl: Label!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func config(type: ChallengeType){
        switch type {
        case .challengeOpen:
            descriptionLbl.text = "Menunggu lawan debat"
        case .challengeDirect:
            descriptionLbl.text = "Menunggu Konfirmasi"
        case .challengeDenied:
            descriptionLbl.text = "Lawan Menolak Tantangan"
            descriptionLbl.textColor = Color.red
        case .challengeExpired:
            descriptionLbl.text = "Tantangan Melebihi Batas Waktu"
            descriptionLbl.textColor = Color.red
        default: break
        }
    }

}
