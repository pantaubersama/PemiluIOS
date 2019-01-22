//
//  UndangAnggotaController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class UndangAnggotaController: UIViewController {

    var viewModel: UndangAnggotaViewModel!
    lazy var disposeBag = DisposeBag()
    @IBOutlet weak var containerLink: RoundView!
    @IBOutlet weak var tfLink: TextField!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var lblState: Label!
    @IBOutlet weak var tfEmail: TextField!
    @IBOutlet weak var btnUndang: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Undang Anggota"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        // MARK
        // bind View Model
        back.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        tfEmail.rx.text.orEmpty
            .bind(to: viewModel.input.emailTrigger)
            .disposed(by: disposeBag)
        
        btnUndang.rx.tap
            .bind(to: viewModel.input.undangTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.createSelected
            .drive()
            .disposed(by: disposeBag)
        
        switchButton.rx.isOn
            .do(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.lblState.text  = value ? "Link aktif" : "Link tidak aktif"
                self.containerLink.backgroundColor = value ? Color.primary_white : Color.grey_three
                self.tfLink.backgroundColor = value ? Color.primary_white : Color.grey_three
                self.tfLink.isEnabled = value
            })
            .bind(to: viewModel.input.switchTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.switchSelected
            .drive(onNext: { [weak self] (s) in
                guard let `self` = self else { return }
                self.tfLink.text = "https://pantaubersama.com/magic/link/\(s)"
            })
            .disposed(by: disposeBag)
        
        viewModel.output.switchLabelSelected
            .drive(onNext: { [weak self] (s) in
                self?.lblState.text = s
            })
            .disposed(by: disposeBag)
        
        viewModel.output.userData
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                if let state = response.cluster?.isLinkActive {
                    self.switchButton.isOn = state
                    self.lblState.text = state ? "Link aktif" : "Link tidak aktif"
                    self.containerLink.backgroundColor = state ? Color.primary_white : Color.grey_three
                    self.tfLink.backgroundColor = state ? Color.primary_white : Color.grey_three
                    self.tfLink.isEnabled = state
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.enable
            .do(onNext: { [weak self] (enable) in
                guard let `self` = self else { return }
                self.btnUndang.backgroundColor = enable ? Color.primary_red : Color.grey_three
            })
            .drive(btnUndang.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.configure(with: .white)
    }

}
