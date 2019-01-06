//
//  QuizOngoingCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift

protocol QuizOngoingNavigator { 
    func openQuizResult(finishQuiz: Bool) -> Observable<Void>
    func exitQuiz()
}

class QuizOngoingCoordinator: BaseCoordinator<Void>, QuizOngoingNavigator {
    let navigationController: UINavigationController
    let quiz: QuizModel
    
    init(navigationController: UINavigationController, quiz: QuizModel) {
        self.navigationController = navigationController
        self.quiz = quiz
    }
    
    override func start() -> Observable<Void> {
        let viewController = QuizOngoingController()
        let viewModel = QuizOngoingViewModel(navigator: self, quiz: quiz)
        viewController.viewModel = viewModel
        var viewControllers: [UIViewController] = []
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(viewController, animated: true)
        self.navigationController.viewControllers.forEach({ (vc) in
            if vc.isKind(of: PenpolController.self) || vc.isKind(of: QuizOngoingController.self){
                viewControllers.append(vc)
            }
        })
        
        self.navigationController.viewControllers = viewControllers
        return Observable.never()
    }
    
    func openQuizResult(finishQuiz: Bool) -> Observable<Void> {
        let quizResultCoordinator = QuizResultCoordinator(navigationController: self.navigationController)
        
        if finishQuiz {
            return coordinate(to: quizResultCoordinator)
        } else {
            return Observable.never()
        }
        
    }
    
    func exitQuiz() {
        self.navigationController.popViewController(animated: true)
    }
    
}
