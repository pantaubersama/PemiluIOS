//
//  SearchController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 13/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SearchController: UIViewController {
    @IBOutlet weak var navbar: SearchNavbar!
    @IBOutlet weak var customMenuBar: CustomMenuBar!
    @IBOutlet weak var container: UIView!
    
    var viewModel: SearchViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customMenuBar.menuItem = [MenuItem(title: "a"),
                                  MenuItem(title: "b"),
                                  MenuItem(title: "c"),
                                  MenuItem(title: "d"),
                                  MenuItem(title: "e"),
                                  MenuItem(title: "f")]
        navbar.btnBack.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

}
