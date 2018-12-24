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
    // TODO: replace Any with Quiz model
    func shareQuizResult() -> Observable<Any>
    func openAnswerKey() -> Observable<Any>
}

class QuizResultCoordinator: BaseCoordinator<Void> {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = QuizResultController()
        let viewModel = QuizResultViewModel(navigator: self)
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
        
        return viewModel.output.back.do(onNext: { [weak self](_) in
            self?.navigationController.popViewController(animated: true)
        }).asObservable()
    }
}

extension QuizResultCoordinator: QuizResultNavigator {
    func shareQuizResult() -> Observable<Any> {
        return Observable.never()
    }
    
    func openAnswerKey() -> Observable<Any> {
        return Observable.never()
    }
}
