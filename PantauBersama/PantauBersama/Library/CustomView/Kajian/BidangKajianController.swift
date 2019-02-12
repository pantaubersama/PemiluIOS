//
//  BidangKajianController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BidangKajianController: UIViewController {
    
    var viewModel: BidangKajianViewModel!
    
    private let tap: UITapGestureRecognizer = UITapGestureRecognizer()
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        tap.rx.event
            .bind(to: viewModel.input.cancelI)
            .disposed(by: disposeBag)
    }
    
}
