//
//  RefuseChallengeView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit

// actual size 120
@IBDesignable
class RefusewChallengeView: UIView {
    
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
    
}
