//
//  RekapDetailTPSFooter.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class RekapDetailTPSFooter: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    lazy var c1SummaryPemilihView = C1SummaryPemilihView()
    lazy var c1SuratSuaraView = UIView.nib(withType: C1SuratSuaraView.self)
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1000 + 472)
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
        
        configureView()
    }
    
    private func configureView() {
        stackView.addArrangedSubview(c1SummaryPemilihView)
        stackView.addArrangedSubview(c1SuratSuaraView)
    }
    
}
