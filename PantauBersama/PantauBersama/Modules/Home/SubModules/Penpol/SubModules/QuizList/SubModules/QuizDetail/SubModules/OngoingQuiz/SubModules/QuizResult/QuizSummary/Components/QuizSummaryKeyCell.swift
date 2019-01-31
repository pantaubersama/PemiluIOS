//
//  QuizAnswerKeyCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class QuizSummaryKeyCell: UITableViewCell, IReusableCell {
    struct Input {
        let question: QuizSummaryModel
        let order: Int
    }
    
    @IBOutlet weak var lbQuestionNo: Label!
    @IBOutlet weak var lbQuestion: Label!
    @IBOutlet weak var lbPaslonA: Label!
    @IBOutlet weak var lbPaslonAAnswer: Label!
    @IBOutlet weak var lbPaslonB: Label!
    @IBOutlet weak var lbPaslonBAnswer: Label!
    @IBOutlet weak var lbMyAnswer: Label!
    
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func configureCell(item: Input) {
        lbQuestionNo.text = "Pertanyaan " + item.order.stringOrder
        lbQuestion.text = item.question.content
        lbPaslonA.text = item.question.answers[0].team.title
        lbPaslonAAnswer.setHTML(html: item.question.answers[0].content)
        lbPaslonB.text = item.question.answers[1].team.title
        lbPaslonBAnswer.setHTML(html: item.question.answers[1].content)
        lbMyAnswer.text = item.question.answered.team.title
    }
    
}
