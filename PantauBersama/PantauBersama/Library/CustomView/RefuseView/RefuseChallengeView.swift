//
//  RefuseChallengeView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Networking
import Common

// actual size 120
@IBDesignable
class RefuseChallengeView: UIView {
    
    @IBOutlet weak var ivOpponents: CircularUIImageView!
    @IBOutlet weak var lblName: Label!
    @IBOutlet weak var lblUsername: Label!
    @IBOutlet weak var lblReason: Label!
    
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
    
    func configureData(data: [Audiences]) {
        let opponents = data.filter({ $0.role != .challenger }).first // cause direct just have one audiences
        ivOpponents.show(fromURL: opponents?.avatar?.thumbnail.url ?? "")
        lblName.text = opponents?.fullName
        lblUsername.text = opponents?.username
        
    }
}
