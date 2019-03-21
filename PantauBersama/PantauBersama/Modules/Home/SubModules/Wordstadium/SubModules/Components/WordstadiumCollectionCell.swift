//
//  WordstadiumCollectionCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking

class WordstadiumCollectionCell: UICollectionViewCell {

    @IBOutlet weak var backgroundItem: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var moreMenuBtn: UIButton!
    @IBOutlet weak var leftPersonIv: UIImageView!
    @IBOutlet weak var leftUsername: UILabel!
    @IBOutlet weak var rightPersonIv: UIImageView!
    @IBOutlet weak var rightUsername: UILabel!
    @IBOutlet weak var statementLbl: UILabel!
    @IBOutlet weak var topicLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

extension WordstadiumCollectionCell: IReusableCell {
    
    struct Input {
        let type : LiniType
        let wordstadium: Challenge
    }
    
    func configureCell(item: Input) {
        let chellenge = item.wordstadium
        let challenger = chellenge.audiences.filter({ $0.role == .challenger }).first
        let opponent = chellenge.audiences.filter({ $0.role == .opponent }).first
        
        topicLbl.text = chellenge.topic?.first ?? ""
        statementLbl.text = chellenge.statement
        
        // configure header challenger side
        leftUsername.text = challenger?.fullName ?? ""
        leftPersonIv.show(fromURL: challenger?.avatar?.url ?? "")
        
        // configure header opponent side
        rightUsername.text = opponent?.fullName ?? ""
        rightPersonIv.show(fromURL: opponent?.avatar?.url ?? "")
        
        
        switch item.type {
        case .public:
            backgroundItem.image = UIImage(named: "bgWordstadiumLive")
            titleLbl.text = "Live Now"
        case .personal:
            backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
            titleLbl.text = "Open Challenge"
        }
    }
}
