//
//  InputC1PresidenController.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

enum FormC1Type {
    case presiden
    case dpr
    case dpd
    case dprdKota
    case dprdProv
    
    var title: String {
        switch self {
        case .dpd:
            return "DPD"
        case .dpr:
            return "DPR RI"
        case .dprdKota:
            return "DPRD KAB/KOTA"
        case .dprdProv:
            return "DPRD PROVINSI"
        case .presiden:
            return "PRESIDEN"
        }
    }
}

class C1InputFormController: UIViewController {
    var viewModel: C1InputFormViewModel!
    var type: FormC1Type!
    @IBOutlet weak var lblDesc: Label!
    @IBOutlet weak var btnSimpan: Button!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var containerView: UIStackView!
    
    lazy var pemilihView = UIView.nib(withType: C1PemilihView.self)
    lazy var pemilihDisabilitasView = UIView.nib(withType: C1PemilihDisabilitasView.self)
    lazy var suratSuaraView = UIView.nib(withType: C1SuratSuaraView.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = type.title
        lblDesc.text = "Silahkan masukkan data Model C1 \(type.title.lowercased()) pada kolom dibawah ini :"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnSimpan.rx.tap
            .bind(to: viewModel.input.simpanI)
            .disposed(by: disposeBag)

        pemilihView.config(viewModel: viewModel)
        pemilihDisabilitasView.config(viewModel: viewModel)
        suratSuaraView.config(viewModel: viewModel)
        
        containerView.addArrangedSubview(pemilihView)
        containerView.addArrangedSubview(pemilihDisabilitasView)
        containerView.addArrangedSubview(suratSuaraView)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.c1SummaryO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                self.pemilihView.configureInitial(data: response)
                self.pemilihDisabilitasView.configureInitial(data: response)
                self.suratSuaraView.configure(data: response)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.simpanO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.a3O
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.a4O
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.aDpkO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.c7DptO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.c7DptbO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.c7DpkO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.disTerdaftarO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.disHakO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.suratO
            .drive()
            .disposed(by: disposeBag)
        
    }
}
