//
//  AddKategoriController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class AddKategoriController: UIViewController {
    
    @IBOutlet weak var textFieldKategori: TextField!
    @IBOutlet weak var buttonBuat: Button!
    @IBOutlet weak var buttonBatal: Button!
    
    var viewModel: AddKategoriViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        buttonBuat.rx.tap
            .bind(to: viewModel.input.sendI)
            .disposed(by: disposeBag)
        
        buttonBatal.rx.tap
            .bind(to: viewModel.input.cancelI)
            .disposed(by: disposeBag)
        
        textFieldKategori.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.textI)
            .disposed(by: disposeBag)
        
        viewModel.output.isEnabled
            .do(onNext: { [weak self] (enable) in
                guard let `self` = self else { return }
                self.buttonBuat.tintColor = enable ? Color.primary_red : Color.grey_two
            })
            .drive(buttonBuat.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.actionSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.cancelO
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.viewWillAppearI.onNext(())
    }
}
