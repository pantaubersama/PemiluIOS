//
//  QuizDetailCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol QuizDetailNavigator {
    func startQuiz() -> Observable<Void>
    var finish: Observable<Void>! { get set }
}

class QuizDetailCoordinator: BaseCoordinator<Void>, QuizDetailNavigator {
    var finish: Observable<Void>!
    
    private let navigationController: UINavigationController
    private let quiz: QuizModel
    
    // TODO: replace any with Quiz model
    init(navigationController: UINavigationController, quizModel: QuizModel) {
        self.navigationController = navigationController
        self.quiz = quizModel
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = QuizDetailController()
        let viewModel = QuizDetailViewModel(navigator: self, quizModel: quiz)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
    func startQuiz() -> Observable<Void> {
        let quizOngoingCoordinator = QuizOngoingCoordinator(navigationController: self.navigationController, quiz: quiz)
        return coordinate(to: quizOngoingCoordinator)
    }
}
