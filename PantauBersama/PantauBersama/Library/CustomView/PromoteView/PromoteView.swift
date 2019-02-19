//
//  PromoteView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking

// actual height 389

@IBDesignable
class PromoteView: UIView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var containerTwitter: UIView!
    @IBOutlet weak var containerFacebook: UIView!
    @IBOutlet weak var switchTwitter: UISwitch!
    @IBOutlet weak var contentTwitter: Label!
    @IBOutlet weak var switchFacebook: UISwitch!
    @IBOutlet weak var contentFacebook: Label!
    @IBOutlet weak var contraintTopStack: NSLayoutConstraint!
    
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
    
    func configure(type: Bool, data: User) {
        switch type {
        case true: // for direct challenge
            self.containerFacebook.isHidden = true
            self.lblTitle.text = "Tantangan debat kamu,"
            self.lblSubtitle.text = "sudah siap tayang! \n\nHubungkan dengan\nakun Twitter-mu"
            if let statusTwitter = data.twitter {
                switchTwitter.isOn = statusTwitter
                // Read from UserDefaults
                if let username: String? = UserDefaults.Account.get(forKey: .usernameTwitter) {
                    contentTwitter.text = "Ayo undang langsung teman Twittermu untuk berdebat!\n\n\(username ?? "")"
                }
            }
        default: // for open challenge
            self.containerFacebook.isHidden = false
            if let statusTwitter = data.twitter, let statusFacebook = data.facebook {
                switchTwitter.isOn = statusTwitter
                switchFacebook.isOn = statusFacebook
                // Read from UserDefaults
                if let username: String? = UserDefaults.Account.get(forKey: .usernameTwitter) {
                    contentTwitter.text = "Tweet tantangan kamu sekarang. Undang temanmu untuk berdebat di sini.\n\n\(username ?? "")"
                }
                if let usernameFacebook: String? = UserDefaults.Account.get(forKey: .usernameFacebook) {
                    self.contentFacebook.text = "Post tantangan debatmu melalui Facebook. Undang temanmu untuk berdebat di sini.\n\n\(usernameFacebook ?? "")"
                }
            }            
        }
    }
    
}
