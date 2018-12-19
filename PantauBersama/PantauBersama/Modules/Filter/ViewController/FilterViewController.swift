//
//  FilterViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Common

class FilterViewController: UIViewController {
    
    var viewModel: IFilterViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filter"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let reset = UIBarButtonItem(title: "RESET", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = reset
        navigationController?.navigationBar.configure(with: .solid(color: Color.white))
        
//        back.rx.tap
//            .bind(to: viewModel.input.backI)
//            .disposed(by: disposeBag)
    }
    
}
