//
//  Navbar.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit

@IBDesignable
class Navbar: UIView {
    
    @IBOutlet weak var profile: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var note: UIButton!
    @IBOutlet weak var notification: UIButton!
    
    
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
