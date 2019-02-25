//
//  WordstadiumItemViewCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking

class WordstadiumItemViewCell: UITableViewCell {

    @IBOutlet weak var backgroundItem: UIImageView!
    @IBOutlet weak var footerContainerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var vsImage: UIImageView!
    @IBOutlet weak var leftPersonView: RoundView!
    @IBOutlet weak var leftUsername: UILabel!
    @IBOutlet weak var rightPersonView: RoundView!
    @IBOutlet weak var rightUsername: UILabel!
    @IBOutlet weak var rightStatus: UILabel!
    @IBOutlet weak var moreMenuBtn: UIButton!
    @IBOutlet weak var statementLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension WordstadiumItemViewCell: IReusableCell {
    
    struct Input {
        let type: LiniType
        let itemType : ProgressType
        let wordstadium: Challenge
    }
    
    func configureCell(item: Input) {
        var footerView: UIView!
        
        statementLbl.text = item.wordstadium.statement
    
        
        switch item.itemType {
        case .comingSoon:
            backgroundItem.image = UIImage(named: "bgWordstadiumComingsoon")
            footerView = TimeView()
            titleLbl.text = "Coming Soon"
        case .done:
            backgroundItem.image = UIImage(named: "bgWordstadiumDone")
            footerView = ClapView()
            titleLbl.text = "Done"
        case .ongoing:
            backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
            let descView = DescriptionView()
//            descView.config(type: item.wordstadium.type)
            footerView = descView
            
//            switch item.wordstadium.type {
//            case .challengeOpen:
//                titleLbl.text = "Open Challenge"
//                vsImage.isHidden = false
//                rightPersonView.isHidden = false
//                rightUsername.isHidden = false
//                rightStatus.text = "?"
//            case .challengeDirect:
//                titleLbl.text = "Direct Challenge"
//                vsImage.isHidden = false
//                rightPersonView.isHidden = false
//                rightUsername.isHidden = false
//                rightStatus.text = "?"
//            case .challengeDenied:
//                titleLbl.text = "Denied"
//                vsImage.isHidden = true
//                rightPersonView.isHidden = true
//                rightUsername.isHidden = true
//                rightStatus.text = ""
//            case .challengeExpired:
//                titleLbl.text = "Expired"
//                vsImage.isHidden = true
//                rightPersonView.isHidden = true
//                rightUsername.isHidden = true
//                rightStatus.text = ""
//            default: break
//            }
            
        case .liveNow:
            if item.type == .public {
                backgroundItem.image = UIImage(named: "bgWordstadiumLive")
                titleLbl.text = "Live Now"
                footerView = TimeView()
            } else {
                backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
                titleLbl.text = "Open Challenge"
            }
            
        }
        
        footerContainerView.addSubview(footerView)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // MARK: constraint footerView
            footerView.leadingAnchor.constraint(equalTo: footerContainerView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: footerContainerView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: footerContainerView.topAnchor),
            footerView.bottomAnchor.constraint(equalTo: footerContainerView.bottomAnchor)
            ])
        
    }
}
