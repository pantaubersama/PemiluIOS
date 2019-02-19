//
//  DebatDetailController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 18/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class DebatDetailController: UIViewController {
    
    var viewModel: DebatDetailViewModel!
    @IBOutlet weak var btnClose: ImageButton!
    @IBOutlet weak var viewChallengeDetail: ChallengeDetailView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnClose.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
        // Do any additional setup after loading the view.
    }

}
