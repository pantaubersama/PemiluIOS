//
//  UpdatesView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class UpdatesView: UIViewController {
    
    @IBOutlet weak var lblInfo: Label!
    @IBOutlet weak var btnUpdateNow: Button!
    @IBOutlet weak var btnSkipUpdate: Button!
    @IBOutlet weak var btnForceUpdate: Button!
    
    var viewModel: UpdatesViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        btnForceUpdate.rx.tap
            .bind(to: viewModel.input.updateI)
            .disposed(by: disposeBag)
        
        btnUpdateNow.rx.tap
            .bind(to: viewModel.input.updateI)
            .disposed(by: disposeBag)
        
        btnSkipUpdate.rx.tap
            .bind(to: viewModel.input.nextTimeI)
            .disposed(by: disposeBag)
        
        viewModel.output.typeO
            .do(onNext: { [weak self] (type) in
                guard let `self` = self else { return }
                switch type {
                case .major:
                    self.btnSkipUpdate.isHidden = true
                    self.btnUpdateNow.isHidden = true
                case .minor:
                    self.btnForceUpdate.isHidden = true
                    self.btnSkipUpdate.isHidden = false
                    self.btnUpdateNow.isHidden = false
                }
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.updateO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.nextTimeO
            .drive()
            .disposed(by: disposeBag)
    }
    
    
}
