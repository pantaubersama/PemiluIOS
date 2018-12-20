//
//  OnboardingViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Common

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var buttonMulai: Button!
    @IBOutlet weak var buttonLewati: UIButton!
    
    var viewModel: OnboardingViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonMulai.rx.tap
            .bind(to: viewModel.input.siginTrigger)
            .disposed(by: disposeBag)

        buttonLewati.rx.tap
            .bind(to: viewModel.input.bypassTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.siginSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.bypassSelected
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
