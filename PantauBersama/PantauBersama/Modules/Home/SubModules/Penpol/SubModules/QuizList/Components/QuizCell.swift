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
    struct Input {
        let viewModel: QuizViewModel
        let quiz: QuizModel
    }
    @IBOutlet weak var ivQuiz: UIImageView!
    @IBOutlet weak var lbTitle: Label!
    @IBOutlet weak var lbTotalQuestion: Label!
    @IBOutlet weak var btnQuiz: QuizButton!
    @IBOutlet weak var btnShare: UIButton!
    
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        btnQuiz.setTitle("", for: .normal)
    }
    
    func configureCell(item: Input) {
        ivQuiz.show(fromURL: item.quiz.image.medium.url)
        lbTitle.text = item.quiz.title
        lbTotalQuestion.text = item.quiz.subtitle
        
        btnQuiz.setState(state: item.quiz.participationStatus)
        
        btnQuiz.rx.tap
            .map({ item.quiz })
            .bind(to: item.viewModel.input.openQuizTrigger)
            .disposed(by: disposeBag)
        
        btnShare.rx.tap
            .map({ item.quiz })
            .bind(to: item.viewModel.input.shareTrigger)
            .disposed(by: disposeBag)
    }
}
