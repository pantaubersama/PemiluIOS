//
//  BiodataView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 28/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit

@IBDesignable
class BiodataView: UIView {
    
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
