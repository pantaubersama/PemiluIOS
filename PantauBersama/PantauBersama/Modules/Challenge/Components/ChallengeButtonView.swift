//
//  ChallengeButtonView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

@IBDesignable
class ChallengeButtonView: UIView {
    
    @IBOutlet weak var containerLike: UIView!
    @IBOutlet weak var btnShare: Button!
    @IBOutlet weak var btnMore: UIButton!
    
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

    func configure(type: ChallengeType) {
        switch type {
        case .done:
            containerLike.isHidden = false
        default:
            break
        }
    }
    
}
