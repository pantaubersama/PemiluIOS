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
        
        viewModel.output.createSelected
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.configure(with: .white)
    }

}
