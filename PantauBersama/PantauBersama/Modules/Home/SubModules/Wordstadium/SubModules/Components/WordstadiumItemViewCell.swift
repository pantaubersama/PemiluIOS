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
    @IBOutlet weak var leftPersonIv: UIImageView!
    @IBOutlet weak var leftUsername: UILabel!
    @IBOutlet weak var rightPersonView: RoundView!
    @IBOutlet weak var rightPersonIv: UIImageView!
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
        titleLbl.text = item.wordstadium.type.title
        rightPersonView.isHidden = true
        rightUsername.text = ""
        
        for person in item.wordstadium.audiences {
            if person.role == .challenger {
                leftUsername.text = person.fullName ?? ""
                if let thumbnailUrl = person.avatar?.thumbnail.url {
                    leftPersonIv.af_setImage(withURL: URL(string: thumbnailUrl)!)
                }
            } else {
                rightUsername.text = person.fullName ?? ""
                if let thumbnailUrl = person.avatar?.thumbnail.url {
                    rightPersonIv.af_setImage(withURL: URL(string: thumbnailUrl)!)
                }
            }
        }
        
        switch item.itemType {
        case .comingSoon:
            backgroundItem.image = UIImage(named: "bgWordstadiumComingsoon")
            footerView = TimeView()
        case .done:
            backgroundItem.image = UIImage(named: "bgWordstadiumDone")
            footerView = ClapView()
        case .ongoing:
            backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
            guard let progress = item.wordstadium.progress else {return}
            
            let descView = DescriptionView()
            descView.descriptionLbl.text = progress.title
            switch progress {
            case .waitingConfirmation:
                descView.descriptionLbl.textColor = Color.gray
                rightPersonView.isHidden = false
            case .waitingOpponent:
                descView.descriptionLbl.textColor = Color.gray
            default:
                descView.descriptionLbl.textColor = Color.red
            }
            
            footerView = descView
        case .liveNow:
            if item.type == .public {
                backgroundItem.image = UIImage(named: "bgWordstadiumLive")
                footerView = TimeView()
            } else {
                backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
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
