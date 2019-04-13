//
//  TPSInputFooter.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class TPSInputFooter: UIView {
    
    @IBOutlet weak var tfTotalPartyCount: TPSTextField!
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 55.0)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setup() {
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func configure(footerCount: Int) {
        tfTotalPartyCount.text = "\(footerCount)"
    }
}
