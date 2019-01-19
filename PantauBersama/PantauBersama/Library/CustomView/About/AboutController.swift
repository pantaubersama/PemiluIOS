//
//  AboutController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 16/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxCocoa
import RxSwift

class AboutController: UIViewController {
    
    @IBOutlet weak var version: Label!
    @IBOutlet weak var buttonLisensi: Button!
    @IBOutlet weak var buttonClose: UIButton!
    
    var viewModel: AboutViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonClose.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        version.text = "Versi \(versionString())"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}
