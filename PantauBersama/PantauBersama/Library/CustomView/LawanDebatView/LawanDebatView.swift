//
//  LawanDebatView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class LawanDebatView: UIView {
    
    // Height 60.0
    @IBOutlet weak var ivAvatar: CircularUIImageView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lblFullname: Label!
    @IBOutlet weak var lblUsername: Label!
    
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
    
    func configure(data: ChallengeModel) {
        
    }
}
