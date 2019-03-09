//
//  LawanDebatView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking

class LawanDebatView: UIView {
    
    // Height 60.0
    @IBOutlet weak var ivAvatar: CircularUIImageView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lblFullname: Label!
    @IBOutlet weak var lblUsername: Label!
    
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
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func configure(data: ChallengeModel) {
        if let url = data.userAvatar {
            ivAvatar.show(fromURL: url)
        } else {
            ivAvatar.image = #imageLiteral(resourceName: "icDummyPerson")
        }
        lblUsername.text = data.opponentUsername
        lblFullname.text = data.opponentName
        if data.opponentStatus == true {
            // case from symbolic
            ivStatus.image = #imageLiteral(resourceName: "icSymbolic")
        } else {
            ivStatus.image = #imageLiteral(resourceName: "flatTwitterBadge72Px")
        }
    }
    
    func configureOpponents(data: Challenge) {
        let opponents = data.audiences.filter({ $0.role != .challenger })
        if let url = opponents.first?.avatar?.thumbnail.url {
            ivAvatar.show(fromURL: url)
        } else {
            ivAvatar.image = #imageLiteral(resourceName: "icDummyPerson")
        }
        lblUsername.text = opponents.first?.username
        lblFullname.text = opponents.first?.fullName
        // need status response from twitter or not
    }
}
