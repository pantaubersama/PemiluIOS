//
//  SubmitTPSConfirmationController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 26/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxCocoa
import RxSwift

class SubmitTPSConfirmationController: UIViewController {
    @IBOutlet weak var viewConfirmation: RoundView!
    @IBOutlet weak var viewLoading: RoundView!
    @IBOutlet weak var viewSubmitSuccess: RoundView!
    @IBOutlet weak var btnBack: Button!
    @IBOutlet weak var btnNo: Button!
    @IBOutlet weak var btnYes: Button!
    
    var viewModel: DetailTPSViewModel!
    
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: DetailTPSViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.rx.tap
            .bind { [unowned self] in
                self.dismiss(animated: true, completion: {
                    self.viewModel.input.successSubmitI.onNext(())
                })
            }
            .disposed(by: disposeBag)

        btnNo.rx.tap
            .bind { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        // for dummy simulation
        btnYes.rx.tap
            .bind { [unowned self] in
                self.viewConfirmation.isHidden = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.viewLoading.isHidden = true
                })
            }
            .disposed(by: disposeBag)
        
        viewModel.output.successSubmitO
            .drive()
            .disposed(by: disposeBag)
        
    }



}
