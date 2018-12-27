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

class UndangAnggotaController: UIViewController {

    var viewModel: UndangAnggotaViewModel!
    lazy var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buat Pertanyaan"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        // MARK
        // bind View Model
        back.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.createSelected
            .drive()
            .disposed(by: disposeBag)
    }

}
