//
//  SuaraCapresViewCell.swift
//  PantauBersama
//
//  Created by asharijuang on 17/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class SuaraCapresViewCell: UIView {

    @IBOutlet weak var lblParticipant: Label!
    @IBOutlet weak var lblUpdated: Label!
    @IBOutlet weak var lblPaslonSatuPercentage: Label!
    @IBOutlet weak var lblPaslonDuaPercentage: Label!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lblRerataSatu: Label!
    @IBOutlet weak var lblRerataDua: Label!
    
    var disposeBag: DisposeBag = DisposeBag()
    
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

extension SuaraCapresViewCell : IReusableCell {

}
