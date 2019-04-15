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
    @IBOutlet weak var btnSimpan: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Presiden"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnSimpan.rx.tap
            .bind(to: viewModel.input.sendI)
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
            .drive(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                 self.tfTotalInvalidValue.text = "\(value)"
            })
            .disposed(by: disposeBag)
        
        viewModel.output.totalSuaraO
            .drive(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.tfTotalValue.text = "\(value)"
            })
            .disposed(by: disposeBag)
        
        viewModel.output.totalValidO
            .drive(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.tfTotalValidValue.text = "\(value)"
            })
            .disposed(by: disposeBag)
        
        viewModel.output.sendO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.invalidO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.dataO
            .drive(onNext: { [weak self] (calculations) in
                guard let `self` = self else { return }
                let suara1 = calculations.candidates?.filter({ $0.actorId == "1"}).first?.totalVote ?? 0
                let suara2 = calculations.candidates?.filter({ $0.actorId == "2"}).first?.totalVote ?? 0
                let suara3 = calculations.invalidVote
                self.suara1Btn.suara = suara1
                self.suara2Btn.suara = suara2
                self.suara3Btn.suara = suara3
                self.tfTotalInvalidValue.text = "\(suara3)"
                self.tfTotalValue.text = "\(suara1 + suara2 + suara3)"
                self.tfTotalValidValue.text = "\(suara1 + suara2)"
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.realCountO
            .drive(onNext: { [weak self] (data) in
                guard let `self` = self else { return }
                if data.status == .published {
                    let groupsSuara: [TPSButton] = [self.suara1Btn,
                                                    self.suara3Btn,
                                                    self.suara2Btn]
                    groupsSuara.forEach({ (button) in
                        button.isEnabled = false
                    })
                    self.btnSimpan.isEnabled = false
                    let btnAttr = NSAttributedString(string: "Data Terkirim",
                                                     attributes: [NSAttributedString.Key.foregroundColor : Color.cyan_warm_light])
                    self.btnSimpan.setAttributedTitle(btnAttr, for: .normal)
                }
                
            })
            .disposed(by: self.disposeBag)
    }
}
