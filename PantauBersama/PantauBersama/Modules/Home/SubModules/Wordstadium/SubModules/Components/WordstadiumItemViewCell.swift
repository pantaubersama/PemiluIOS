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
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var ivLike: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rightPersonIv.image = #imageLiteral(resourceName: "icDummyPerson")
        leftPersonIv.image = #imageLiteral(resourceName: "icDummyPerson")
        rightPersonIv.af_cancelImageRequest()
        leftPersonIv.af_cancelImageRequest()
        backgroundItem.image = nil
    }
    
}

extension WordstadiumItemViewCell: IReusableCell {
    
    struct Input {
        let wordstadium: Challenge
    }
    
    func configureCell(item: Input) {
        var footerView: UIView!
        
        let challenge = item.wordstadium
        let challenger = challenge.audiences.filter({ $0.role == .challenger }).first
        let opponents = challenge.audiences.filter({ $0.role != .challenger })
    
        likeView.isHidden = challenge.progress != .done
        topicLbl.text = challenge.topic?.first ?? ""
        statementLbl.text = challenge.statement
        rightPersonView.isHidden = true
        rightUsername.text = ""
        opponentCountLbl.text = ""
        likeCountLbl.text = "\(item.wordstadium.likeCount ?? 0)"
        
        // configure header challenger side
        leftUsername.text = challenger?.fullName ?? ""
        if let url = challenger?.avatar?.thumbnail.url {
            leftPersonIv.af_setImage(withURL: URL(string: url)!)
        }
        
        // if there is an opponents candidate, then configure header opponent side
        if let opponent = opponents.first {
            rightPersonView.isHidden = false
            if let url = opponent.avatar?.thumbnail.url {
                rightPersonIv.af_setImage(withURL: URL(string: url)!)
            }
            
            if opponent.role == .opponent {
                rightUsername.text = opponent.fullName ?? ""
            } else {
                opponentCountLbl.text = challenge.type == .directChallenge ? "?" : "\(opponents.count)"
            }
        }
        
        switch challenge.progress {
        case .comingSoon:
            titleLbl.text = challenge.progress.title
            backgroundItem.image = UIImage(named: "bgWordstadiumComingsoon")
            let timeView = TimeView()
            if let time = challenge.showTimeAt {
                let timeLimit = Double(challenge.timeLimit ?? 0)
                let mTimeStart = time.date(format: Constant.timeFormat) ?? ""
                let mTimeEnd = time.toDate(format: Constant.dateTimeFormat3)?.addingTimeInterval(timeLimit * 60).toString(format: Constant.timeFormat) ?? ""
                
                timeView.dateLbl.text = time.date(format: Constant.dateFormat2)
                timeView.timeLbl.text = mTimeStart  + " - " + mTimeEnd
            }
            
            footerView = timeView
        case .liveNow:
            titleLbl.text = challenge.progress.title
            backgroundItem.image = UIImage(named: "bgWordstadiumLive")
            let descView = DescriptionView()
            descView.descriptionLbl.text = "Live Selama \(challenge.timeLimit ?? 0) Menit"
            footerView = descView
        case .done:
            titleLbl.text = challenge.progress.title
            backgroundItem.image = UIImage(named: "bgWordstadiumDone")
            let clapView = ClapView()
            clapView.challengerClapLbl.text = "\(challenge.challenger?.clapCount ?? 0)"
            clapView.opponentClapLbl.text = "\(challenge.opponents.first?.clapCount ?? 0)"
            footerView = clapView
        case .waitingConfirmation,.waitingOpponent:
            titleLbl.text = challenge.type.title
            backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
            let descView = DescriptionView()
            
            switch challenge.condition {
            case .expired, .rejected:
                descView.descriptionLbl.text = challenge.condition.title
                descView.descriptionLbl.textColor = Color.red
            default:
                descView.descriptionLbl.text = challenge.progress.title
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
