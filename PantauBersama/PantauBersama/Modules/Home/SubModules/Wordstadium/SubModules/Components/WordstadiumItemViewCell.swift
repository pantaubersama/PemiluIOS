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
    @IBOutlet weak var opponentCountLbl: UILabel!
    
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
        var opponentCount: Int = 0
        
        guard let topics = item.wordstadium.topic else {return}
        var topicStr = ""
        for topic in topics {
            topicStr += " \(topic)"
        }
        topicLbl.text = topicStr
        
        titleLbl.text = item.wordstadium.progress.title
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
                rightPersonView.isHidden = false
                if let thumbnailUrl = person.avatar?.thumbnail.url {
                    rightPersonIv.af_setImage(withURL: URL(string: thumbnailUrl)!)
                }
            case .opponentCandidate:
                rightUsername.text = ""
                rightPersonView.isHidden = false
                if let thumbnailUrl = person.avatar?.thumbnail.url {
                    rightPersonIv.af_setImage(withURL: URL(string: thumbnailUrl)!)
                }
                
                if item.wordstadium.type == .directChallenge {
                    opponentCountLbl.text = "?"
                } else {
                    opponentCount += 1
                    opponentCountLbl.text = "\(opponentCount)"
                }
            default :
                break
            }
        }
        
        switch item.wordstadium.progress {
        case .comingSoon:
            backgroundItem.image = UIImage(named: "bgWordstadiumComingsoon")
            let timeView = TimeView()
            if let time = item.wordstadium.showTimeAt {
                let timeLimit = Double(item.wordstadium.timeLimit ?? 0)
                let mTimeStart = time.date(format: Constant.timeFormat) ?? ""
                let mTimeEnd = time.toDate(format: Constant.dateTimeFormat3)?.addingTimeInterval(timeLimit * 60).toString(format: Constant.timeFormat) ?? ""
                
                timeView.dateLbl.text = time.date(format: Constant.dateFormat2)
                timeView.timeLbl.text = mTimeStart  + " - " + mTimeEnd
            }
            
            footerView = timeView
        case .liveNow:
            backgroundItem.image = UIImage(named: "bgWordstadiumLive")
            let descView = DescriptionView()
            footerView = descView
        case .done:
            backgroundItem.image = UIImage(named: "bgWordstadiumDone")
            let clapView = ClapView()
            
            footerView = clapView
        case .waitingConfirmation,.waitingOpponent:
            backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
            let descView = DescriptionView()
            
            switch item.wordstadium.condition {
            case .expired, .rejected:
                descView.descriptionLbl.text = item.wordstadium.condition.title
                descView.descriptionLbl.textColor = Color.red
            default:
                descView.descriptionLbl.text = item.wordstadium.progress.title
                descView.descriptionLbl.textColor = Color.gray
            }
            
            footerView = descView
        default:
            break
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
