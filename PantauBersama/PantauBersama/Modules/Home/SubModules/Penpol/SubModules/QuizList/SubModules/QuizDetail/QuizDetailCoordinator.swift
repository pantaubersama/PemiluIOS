//
//  QuizDetailCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import FBSDKCoreKit

protocol QuizDetailNavigator {
    func startQuiz() -> Observable<Void>
    func finish() -> Observable<Void>
}

class QuizDetailCoordinator: BaseCoordinator<Void>, QuizDetailNavigator {
    private let navigationController: UINavigationController
    private let quiz: QuizModel
    
    // TODO: replace any with Quiz model
    init(navigationController: UINavigationController, quizModel: QuizModel) {
        self.navigationController = navigationController
        self.quiz = quizModel
    }
    
    override func start() -> Observable<CoordinationResult> {
        FBSDKAppEvents.logEvent("Quiz Detail", parameters: ["content_id": quiz.id])
        let viewController = QuizDetailController()
        let viewModel = QuizDetailViewModel(navigator: self, quizModel: quiz)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        
        return Observable.never()
    }
    
    func startQuiz() -> Observable<Void> {
        let quizOngoingCoordinator = QuizOngoingCoordinator(navigationController: self.navigationController, quiz: quiz)
        return coordinate(to: quizOngoingCoordinator)
    }
    
    func finish() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        
        return Observable.never()
    }
}
