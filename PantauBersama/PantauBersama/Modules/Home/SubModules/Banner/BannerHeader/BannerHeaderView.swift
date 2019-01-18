//
//  BannerHeaderView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking
import RxSwift

class BannerHeaderView: UIView {

    @IBOutlet weak var ivInfoBackground: UIImageView!
    @IBOutlet weak var body: Label!
    private(set) var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 115)
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        disposeBag = DisposeBag()
        
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func config(banner: BannerInfo, viewModel: BannerHeaderViewModel) {
        body.text = banner.body
        
        switch banner.pageName {
        case .tanya:
            ivInfoBackground.image = UIImage(named: "icBannerAsk")
        case .kuis:
            ivInfoBackground.image = UIImage(named: "icBannerQuestion")
        case .janji_politik:
            ivInfoBackground.image = UIImage(named: "icHeaderJanpol")
        case .pilpres:
            ivInfoBackground.image = UIImage(named: "icHeaderPilpres")
        case .unknown:
            return
        }
        
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.mapToVoid()
            .map({ banner })
            .bind(to: viewModel.input.itemSelected)
            .disposed(by: disposeBag)
    }
    
    
}
