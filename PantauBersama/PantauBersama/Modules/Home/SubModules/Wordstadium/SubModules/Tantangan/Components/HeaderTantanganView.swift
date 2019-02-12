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

enum HeaderTantanganType {
    case open
    case direct
}

class HeaderTantanganView: UIView {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblUsername: Label!
    @IBOutlet weak var lblType: UILabel!
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 123.0)
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
            lblType.text = "OPEN CHALLENGE"
        case .direct:
            lblType.text = "DIRECT CHALLENGE"
        }
    }
    
}
