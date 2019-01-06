//
//  BiodataView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 28/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking


class BiodataView: UIView {
    @IBOutlet weak var labelLocation: Label!
    @IBOutlet weak var labelEducation: Label!
    @IBOutlet weak var labelOccupation: Label!
    
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
    
    func configure(data: User) {
        labelLocation.text = data.informant?.address
        labelEducation.text = data.education
        labelOccupation.text = data.informant?.occupation
    }
    
}
