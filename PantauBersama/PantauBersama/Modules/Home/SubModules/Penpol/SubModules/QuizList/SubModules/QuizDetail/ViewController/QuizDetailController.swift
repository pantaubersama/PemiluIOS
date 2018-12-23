//
//  QuizDetailController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class QuizDetailController: UIViewController {
    @IBOutlet weak var ivQuiz: UIImageView!
    @IBOutlet weak var lbTitle: Label!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var lbQuestionCount: Label!
    @IBOutlet weak var btnStart: Button!
    
    var viewModel: QuizDetailViewModel!
    lazy var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        btnStart.rx.tap
            .bind(to: viewModel.input.startTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.startSelected
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.configure(with: .transparent)
        self.navigationController?.navigationBar.tintColor = UIColor.clear
    }

}
