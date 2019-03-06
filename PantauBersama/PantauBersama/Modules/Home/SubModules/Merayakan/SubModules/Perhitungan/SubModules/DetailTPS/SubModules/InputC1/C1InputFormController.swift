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
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var containerView: UIStackView!
    
    lazy var pemilihView = UIView.nib(withType: C1PemilihView.self)
    lazy var pemilihDisabilitasView = UIView.nib(withType: C1PemilihDisabilitasView.self)
    lazy var suratSuaraView = UIView.nib(withType: C1SuratSuaraView.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = type.title
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)

        containerView.addArrangedSubview(pemilihView)
        containerView.addArrangedSubview(pemilihDisabilitasView)
        containerView.addArrangedSubview(suratSuaraView)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
    }
}
