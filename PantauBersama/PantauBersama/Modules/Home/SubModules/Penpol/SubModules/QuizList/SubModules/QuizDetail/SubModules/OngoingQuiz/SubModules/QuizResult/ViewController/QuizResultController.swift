//
//  QuizResultController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class QuizResultController: UIViewController {
    
    @IBOutlet weak var lbResult: Label!
    @IBOutlet weak var lbPercent: Label!
    @IBOutlet weak var lbPaslon: Label!
    @IBOutlet weak var btnShare: Button!
    @IBOutlet weak var btnAnswerKey: Button!
    @IBOutlet weak var ivPaslon: UIImageView!
    
    var viewModel: QuizResultViewModel!
    
    private(set) var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.output.result
            .drive(onNext: { [weak self](result) in
                guard let weakSelf = self else { return }
                weakSelf.lbPaslon.text = result.name
                weakSelf.lbPercent.text = result.percentage
                weakSelf.lbResult.text = result.resultSummary
                weakSelf.ivPaslon.show(fromURL: result.avatar)
            }).disposed(by: disposeBag)
        
        viewModel.output.openSummary
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
        
        btnAnswerKey.rx.tap
            .bind(to: viewModel.input.openSummaryTrigger)
            .disposed(by: disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = back
        self.navigationController?.navigationBar.configure(with: .transparent)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        
        // TODO: for mock only, move navigation to coordinator
        back.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
    }
}
