//
//  LinkPreviewView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

@IBDesignable
class LinkPreviewView: UIView {
    
    @IBOutlet weak var btnCloseLink: UIButton!
    @IBOutlet weak var lblLink: Label!
    @IBOutlet weak var ivAvatarLink: CircularUIImageView!
    @IBOutlet weak var lblContent: Label!
    @IBOutlet weak var lblDescContent: Label!
    
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


