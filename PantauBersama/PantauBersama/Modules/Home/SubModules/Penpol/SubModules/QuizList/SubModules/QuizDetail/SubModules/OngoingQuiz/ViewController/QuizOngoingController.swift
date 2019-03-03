//
//  QuizOngoingController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxCocoa
import RxSwift

class QuizOngoingController: UIViewController {
    @IBOutlet weak var btnAChoice: Button!
    @IBOutlet weak var btnBChoice: Button!
    @IBOutlet weak var tvBChoice: UITextView!
    @IBOutlet weak var tvAChoice: UITextView!
    @IBOutlet weak var lbQuestion: UITextView!
    @IBOutlet weak var ivQuiz: UIImageView!
    
    private(set) var disposeBag = DisposeBag()
    var viewModel: QuizOngoingViewModel!
    private var answerA: String!
    private var answerB: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAChoice.rx
            .tap
            .map({ self.answerA })
            .bind(to: self.viewModel.input.answerATrigger)
            .disposed(by: self.disposeBag)
        
        btnBChoice.rx
            .tap
            .map({ self.answerB })
            .bind(to: self.viewModel.input.answerBTrigger)
            .disposed(by: self.disposeBag)
        
        viewModel.input
            .loadQuestionTrigger
            .onNext(())
        
        viewModel.output.answerA
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.answerB
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
        
        // statis images
//        viewModel.output.quiz
//            .drive(onNext: { [unowned self]quiz in
//                self.ivQuiz.show(fromURL: quiz.image.url)
//            })
//            .disposed(by: disposeBag)
        
        viewModel.output.question
            .drive(onNext: { [unowned self]question in
                self.lbQuestion.text = question.content
                self.tvAChoice.setAttributedHtmlText(question.answers[0].content)
                self.answerA = question.answers[0].content
                self.tvBChoice.setAttributedHtmlText(question.answers[1].content)
                self.answerB = question.answers[1].content
            }).disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let quizIndex = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        quizIndex.tintColor = .white
        
        viewModel.output.questionsIndexTitle
            .drive(quizIndex.rx.title)
            .disposed(by: disposeBag)
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = back
        self.navigationItem.rightBarButtonItem = quizIndex
        self.navigationController?.navigationBar.configure(with: .transparent)
        
        back.rx.tap
            .bind(to: viewModel.input.backTrigger).disposed(by: disposeBag)
    }
}
