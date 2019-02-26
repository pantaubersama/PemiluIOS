//
//  FooterProfileView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking

@IBDesignable
class FooterProfileView: UIView {
    
    @IBOutlet weak var ivAvatar: CircularUIImageView!
    @IBOutlet weak var lblName: Label!
    @IBOutlet weak var lblStatus: Label!
    
    @IBOutlet weak var postTime: Label!
    
    // Height 200.0
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

    func configure(data: User) {
        if let url = data.avatar.thumbnail.url {
            ivAvatar.show(fromURL: url)
        }
        lblName.text = data.fullName
        lblStatus.text = data.about
    }
    
}
