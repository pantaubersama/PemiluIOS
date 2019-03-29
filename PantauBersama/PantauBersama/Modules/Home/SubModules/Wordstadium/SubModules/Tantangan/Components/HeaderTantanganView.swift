//
//  HeaderTantanganView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Networking
import Common

enum HeaderTantanganType: Int {
    case open
    case direct
    case `default`
}

@IBDesignable
class HeaderTantanganView: UIView {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblUsername: Label!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var backgroundChallenge: UIImageView!
    @IBOutlet weak var avatarOpponent: UIImageView!
    @IBOutlet weak var containerOpponent: RoundView!
    @IBOutlet weak var lblCountOpponent: UILabel!
    @IBOutlet weak var lblNameOpponent: UILabel!
    @IBOutlet weak var lblUsernameOpponent: Label!
    @IBOutlet weak var lblStatus: UILabel!
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 139.0)
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
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func configure(data: User, type: HeaderTantanganType) {
        switch type {
        case .open:
            if let avatar = data.avatar.thumbnail.url {
                self.avatar.af_setImage(withURL: URL(string: avatar)!)
            }
            lblFullName.text = data.fullName
            lblUsername.text = "@\(data.username ?? "")"
            lblType.text = "OPEN CHALLENGE"
        case .direct:
            lblType.text = "DIRECT CHALLENGE"
            if let avatar = data.avatar.thumbnail.url {
                self.avatar.af_setImage(withURL: URL(string: avatar)!)
            }
            lblFullName.text = data.fullName
            lblUsername.text = "@\(data.username ?? "")"
        case .default:
            break
        }
    }
    
    func configureType(type: ChallengeType) {
        switch type {
        case .soon:
            self.backgroundChallenge.image = #imageLiteral(resourceName: "bgWordstadiumComingsoon")
            self.containerOpponent.isHidden = false
        case .done:
            self.backgroundChallenge.image = #imageLiteral(resourceName: "headerOnGoing")
            self.containerOpponent.isHidden = false
        case .challenge:
            self.backgroundChallenge.image = #imageLiteral(resourceName: "group1279")
        default:
            break
        }
    }
    
}
