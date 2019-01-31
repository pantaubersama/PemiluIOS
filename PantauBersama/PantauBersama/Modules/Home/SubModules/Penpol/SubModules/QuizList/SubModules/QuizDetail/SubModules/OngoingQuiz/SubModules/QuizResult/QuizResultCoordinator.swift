//
//  QuizResultCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Common

protocol QuizResultNavigator {
    func shareQuizResult(quizModel: QuizModel) -> Observable<Void>
    func openSummary(quizModel: QuizModel) -> Observable<Void>
    func finishQuiz() -> Observable<Void>
}

class QuizResultCoordinator: BaseCoordinator<Void> {
    let navigationController: UINavigationController
    let quiz: QuizModel
    
    init(navigationController: UINavigationController, quiz: QuizModel) {
        self.navigationController = navigationController
        self.quiz = quiz
    }
    
    override func start() -> Observable<Void> {
        let viewController = QuizResultController()
        let viewModel = QuizResultViewModel(navigator: self, quiz: quiz)
        viewController.viewModel = viewModel
        
        var viewControllers: [UIViewController] = []
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(viewController, animated: true)
        self.navigationController.viewControllers.forEach({ (vc) in
            if vc.isKind(of: PenpolController.self) || vc.isKind(of: QuizResultController.self){
                viewControllers.append(vc)
            }
        })
        
        self.navigationController.viewControllers = viewControllers
        
        return Observable.never()
    }
}

extension QuizResultCoordinator: QuizResultNavigator {
    func shareQuizResult(quizModel: QuizModel) -> Observable<Void> {
        let askString = "Kamu sudah ikut? Aku sudah dapat hasilnya 😎 #PantauBersama \(AppContext.instance.infoForKey("URL_WEB"))/share/badge/\(quizModel.id)"
        let activityViewController = UIActivityViewController(activityItems: [askString as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        return Observable.never()
    }
    
    func openSummary(quizModel: QuizModel) -> Observable<Void> {
        let quizSummaryCoordinator = QuizSummaryCoordinator(navigationController: self.navigationController, quiz: self.quiz)
        return coordinate(to: quizSummaryCoordinator)
    }
    
    func finishQuiz() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        return Observable.never()
    }
}
