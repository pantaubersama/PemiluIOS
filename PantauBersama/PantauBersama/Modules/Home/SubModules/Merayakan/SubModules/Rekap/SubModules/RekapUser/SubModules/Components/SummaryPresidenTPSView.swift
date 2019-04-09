//
//  SummaryPresidenTPSView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking
import Common

class SummaryPresidenTPSView: UIView {
    
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblName: Label!
    @IBOutlet weak var lblTPS: Label!
    @IBOutlet weak var lblWilayah: Label!
    @IBOutlet weak var lblPercentagePaslonSatu: Label!
    @IBOutlet weak var lblSummaryPaslonSatu: Label!
    @IBOutlet weak var lblPercentagePaslonDua: Label!
    @IBOutlet weak var lblSummaryPaslonDua: Label!
    @IBOutlet weak var lblSuaraTakSah: Label!
    @IBOutlet weak var lblSuaraSah: Label!
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 262.0)
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
