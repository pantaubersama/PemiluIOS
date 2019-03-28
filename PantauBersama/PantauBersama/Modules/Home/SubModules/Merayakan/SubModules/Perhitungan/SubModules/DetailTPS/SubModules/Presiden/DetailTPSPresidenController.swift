//
//  DetailTPSPresidenController.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 02/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class DetailTPSPresidenController: UIViewController {
    var viewModel: DetailTPSPresidenViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private var suara1Btn: TPSButton!
    @IBOutlet weak var suara3Btn: TPSButton!
    @IBOutlet weak var suara2Btn: TPSButton!
    @IBOutlet weak var tfTotalInvalidValue: TPSTextField!
    @IBOutlet weak var tfTotalValidValue: TPSTextField!
    @IBOutlet weak var tfTotalValue: TPSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Presiden"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        suara1Btn.rx_suara
            .bind(to: viewModel.input.suara1I)
            .disposed(by: disposeBag)
        
        suara2Btn.rx_suara
            .bind(to: viewModel.input.suara2I)
            .disposed(by: disposeBag)
        
        suara3Btn.rx_suara
            .bind(to: viewModel.input.suara3I)
            .disposed(by: disposeBag)
        
        
        viewModel.output.suara1O
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.suara2O
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.suara3O
            .drive()
            .disposed(by: disposeBag)
    }
}
