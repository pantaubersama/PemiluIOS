//
//  CreatePerhitunganController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class CreatePerhitunganController: UIViewController {
    var viewModel: CreatePerhitunganViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Data TPS"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let done = UIBarButtonItem(image: #imageLiteral(resourceName: "icDoneRed"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = done
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
    }

}
