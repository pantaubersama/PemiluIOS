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
        
        let chellenge = item.wordstadium
        let challenger = chellenge.audiences.filter({ $0.role == .challenger }).first
        let opponents = chellenge.audiences.filter({ $0.role != .challenger })
    
        topicLbl.text = chellenge.topic?.first ?? ""
        statementLbl.text = chellenge.statement
        rightPersonView.isHidden = true
        rightUsername.text = ""
        opponentCountLbl.text = ""
        
        // configure header challenger side
        leftUsername.text = challenger?.fullName ?? ""
        leftPersonIv.show(fromURL: challenger?.avatar?.url ?? "")
        
        // if there is an opponents candidate, then configure header opponent side
        if let opponent = opponents.first {
            rightPersonView.isHidden = false
            rightPersonIv.show(fromURL: opponent.avatar?.url ?? "")
            
            if opponent.role == .opponent {
                rightUsername.text = opponent.fullName ?? ""
            } else {
                opponentCountLbl.text = chellenge.type == .directChallenge ? "?" : "\(opponents.count)"
            }
        }
        
        switch chellenge.progress {
        case .comingSoon:
            titleLbl.text = chellenge.progress.title
            backgroundItem.image = UIImage(named: "bgWordstadiumComingsoon")
            let timeView = TimeView()
            if let time = chellenge.showTimeAt {
                let timeLimit = Double(chellenge.timeLimit ?? 0)
                let mTimeStart = time.date(format: Constant.timeFormat) ?? ""
                let mTimeEnd = time.toDate(format: Constant.dateTimeFormat3)?.addingTimeInterval(timeLimit * 60).toString(format: Constant.timeFormat) ?? ""
                
                timeView.dateLbl.text = time.date(format: Constant.dateFormat2)
                timeView.timeLbl.text = mTimeStart  + " - " + mTimeEnd
            }
            
            footerView = timeView
        case .liveNow:
            titleLbl.text = chellenge.progress.title
            backgroundItem.image = UIImage(named: "bgWordstadiumLive")
            let descView = DescriptionView()
            footerView = descView
        case .done:
            titleLbl.text = chellenge.progress.title
            backgroundItem.image = UIImage(named: "bgWordstadiumDone")
            let clapView = ClapView()
            
            footerView = clapView
        case .waitingConfirmation,.waitingOpponent:
            titleLbl.text = chellenge.type.title
            backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
            let descView = DescriptionView()
            
            switch chellenge.condition {
            case .expired, .rejected:
                descView.descriptionLbl.text = chellenge.condition.title
                descView.descriptionLbl.textColor = Color.red
            default:
                descView.descriptionLbl.text = chellenge.progress.title
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
