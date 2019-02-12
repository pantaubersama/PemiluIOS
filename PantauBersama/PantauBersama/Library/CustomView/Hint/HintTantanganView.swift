//
//  HintTantanganView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class HintTantanganView: UIViewController {
    
    var viewModel: HintTantanganViewModel!
    @IBOutlet weak var btnClose: Button!
    
    private let disposeBag: DisposeBag! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnClose.rx.tap
            .bind(to: viewModel.input.closeI)
            .disposed(by: disposeBag)
        
    }
    
}
