//
//  QuizAnswerCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift

class QuizSummaryCoordinator: BaseCoordinator<Void> {
    let navigationController: UINavigationController
    let quiz: QuizModel?
    
    init(navigationController: UINavigationController, quiz: QuizModel?) {
        self.navigationController = navigationController
        self.quiz = quiz
    }
    
    override func start() -> Observable<Void> {
        let viewController = QuizSummaryController()
        let viewModel = QuizSummaryViewModel(quiz: quiz)
        viewController.viewModel = viewModel
        
        navigationController.present(viewController, animated: true, completion: nil)
        
        return viewModel.output.back.do(onNext: { [weak self](_) in
            self?.navigationController.dismiss(animated: true, completion: nil)
        })
        .asObservable()
    }
}
