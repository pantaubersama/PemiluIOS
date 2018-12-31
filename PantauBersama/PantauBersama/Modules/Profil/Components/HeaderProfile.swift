//
//  HeaderProfile.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking

@IBDesignable
class HeaderProfile: UIView {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var username: Label!
    @IBOutlet weak var buttonVerified: Button!
    @IBOutlet weak var status: Label!
    
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
    
    func configure(user: User) {
        if let url = user.avatar.thumbnail.url {
            avatar.af_setImage(withURL: URL(string: url)!)
        }
        username.text = user.firstName ?? ""
        buttonVerified.isSelected = user.verified
        buttonVerified.borderColor = user.verified ? Color.secondary_cyan : Color.grey_three
        buttonVerified.isEnabled = user.verified ? false : true
    }
}
