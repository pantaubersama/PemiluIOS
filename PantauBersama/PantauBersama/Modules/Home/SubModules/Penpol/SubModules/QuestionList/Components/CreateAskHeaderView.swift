//
//  HeaderAskView.swift
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

class CreateAskHeaderView: UIView {
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lbFullname: Label!
    
    private var viewModel: QuestionViewModel?
    
    private(set) var disposeBag = DisposeBag()
    
    convenience init(viewModel: QuestionViewModel) {
        self.init()
        self.viewModel = viewModel
        
        setup()
    }
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 85)
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        self.addGestureRecognizer(tapGesture)
        
        guard let viewModel = self.viewModel else { return }
        tapGesture.rx.event
            .mapToVoid()
            .bind(to: viewModel.input.createTrigger)
            .disposed(by: disposeBag)
        
        
        viewModel.output.userData
            .drive(onNext: { [weak self](userResponse) in
                guard let weakSelf = self, let user = userResponse else { return }
                // TODO: Set user avatar
//                ivAvatar.show(fromURL: userResponse.user.)
                weakSelf.lbFullname.text = (user.user.firstName ?? " ") + " " + (user.user.lastName ?? "")
            })
            .disposed(by: disposeBag)
    }
    
    
}