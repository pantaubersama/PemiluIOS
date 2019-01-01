//
//  BannerInfoAskView.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 29/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import UIKit
import Common
import RxSwift
import RxCocoa

class BannerInfoAskView: UIView {
    private(set) var disposeBag = DisposeBag()
    private var viewModel: QuestionViewModel?
    
    convenience init(viewModel: QuestionViewModel) {
        self.init()
        self.viewModel = viewModel
        setup()
    }
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 92)
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
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        self.addGestureRecognizer(tapGesture)
        
        guard let viewModel = self.viewModel else { return }
        tapGesture.rx.event
            .mapToVoid()
            .bind(to: viewModel.input.infoTrigger)
            .disposed(by: disposeBag)
    }
    
    
}
