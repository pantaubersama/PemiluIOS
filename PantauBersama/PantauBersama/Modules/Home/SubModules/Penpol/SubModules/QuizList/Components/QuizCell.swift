//
//  QuizCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class QuizCell: UITableViewCell, IReusableCell {
    @IBOutlet weak var ivQuiz: UIImageView!
    @IBOutlet weak var lbTitle: Label!
    @IBOutlet weak var lbTotalQuestion: Label!
    @IBOutlet weak var btnQuiz: Button!
    @IBOutlet weak var btnShare: UIButton!
    
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    // TODO: change to Quiz model
    var quiz: Any! {
        didSet {
            // TODO: view configuration
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func bind(viewModel: QuizViewModel) {
        btnQuiz.rx.tap
            .map({ self.quiz })
            .bind(to: viewModel.input.openQuizTrigger)
            .disposed(by: disposeBag)

        btnShare.rx.tap
            .map({ self.quiz })
            .bind(to: viewModel.input.shareTrigger)
            .disposed(by: disposeBag)
    }
    
}
