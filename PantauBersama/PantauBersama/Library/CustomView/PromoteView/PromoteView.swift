//
//  PromoteView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

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
    @IBOutlet weak var heightStackConstant: NSLayoutConstraint!
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
    
    func configure(type: Bool) {
        switch type {
        case true:
            self.lblTitle.text = "Tantangan debat kamu,"
            self.lblSubtitle.text = "sudah siap tayang! \n\nHubungkan dengan\nakun Twitter-mu"
            self.heightStackConstant.constant = 68.5
        default:
            self.containerFacebook.isHidden = false
        }
    }
    
}
