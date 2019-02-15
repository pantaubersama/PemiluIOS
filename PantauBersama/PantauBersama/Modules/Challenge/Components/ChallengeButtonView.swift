//
//  ChallengeButtonView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit

@IBDesignable
class ChallengeButtonView: UIView {
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56.0)
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
