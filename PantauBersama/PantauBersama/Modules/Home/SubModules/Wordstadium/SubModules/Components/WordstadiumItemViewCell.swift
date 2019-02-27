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
    @IBOutlet weak var topicLbl: UILabel!
    
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
        
        guard let topics = item.wordstadium.topic else {return}
        var topicStr = ""
        for topic in topics {
            topicStr += " \(topic)"
        }
        topicLbl.text = topicStr
        
        
        statementLbl.text = item.wordstadium.statement
        rightPersonView.isHidden = true
        rightUsername.text = ""
        
        for person in item.wordstadium.audiences {
            switch person.role {
            case .challenger:
                leftUsername.text = person.fullName ?? ""
                if let thumbnailUrl = person.avatar?.thumbnail.url {
                    leftPersonIv.af_setImage(withURL: URL(string: thumbnailUrl)!)
                }
            case .opponent:
                rightUsername.text = person.fullName ?? ""
                if let thumbnailUrl = person.avatar?.thumbnail.url {
                    rightPersonIv.af_setImage(withURL: URL(string: thumbnailUrl)!)
                }
            default :
                break
            }
        }
        
        switch item.itemType {
        case .comingSoon:
            titleLbl.text = item.wordstadium.progress.title
            backgroundItem.image = UIImage(named: "bgWordstadiumComingsoon")
            footerView = TimeView()
        case .done:
            titleLbl.text = item.wordstadium.progress.title
            backgroundItem.image = UIImage(named: "bgWordstadiumDone")
            footerView = ClapView()
        case .ongoing:
            titleLbl.text = item.wordstadium.type.title
            backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
            
            let descView = DescriptionView()
            
            switch item.wordstadium.progress {
            case .waitingConfirmation:
                descView.descriptionLbl.text = item.wordstadium.progress.title
                descView.descriptionLbl.textColor = Color.gray
                rightPersonView.isHidden = false
            case .waitingOpponent:
                descView.descriptionLbl.text = item.wordstadium.progress.title
                descView.descriptionLbl.textColor = Color.gray
            default:
                break
            }
            
            switch item.wordstadium.condition {
            case .expired, .rejected:
                descView.descriptionLbl.text = item.wordstadium.condition.title
                descView.descriptionLbl.textColor = Color.red
            default: break
            }
            
            footerView = descView
        case .liveNow:
            titleLbl.text = item.wordstadium.progress.title
            let descView = DescriptionView()
            if item.type == .public {
                backgroundItem.image = UIImage(named: "bgWordstadiumLive")
                descView.descriptionLbl.text = "Live selama 20 menit"
                descView.descriptionLbl.textColor = Color.gray
            } else {
                backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
                switch item.wordstadium.progress {
                case .waitingConfirmation:
                    descView.descriptionLbl.text = item.wordstadium.progress.title
                    descView.descriptionLbl.textColor = Color.gray
                    rightPersonView.isHidden = false
                case .waitingOpponent:
                    descView.descriptionLbl.text = item.wordstadium.progress.title
                    descView.descriptionLbl.textColor = Color.gray
                default:
                    break
                }
                
                switch item.wordstadium.condition {
                case .expired, .rejected:
                    descView.descriptionLbl.text = item.wordstadium.condition.title
                    descView.descriptionLbl.textColor = Color.red
                default: break
                }
            }
            footerView = descView
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
