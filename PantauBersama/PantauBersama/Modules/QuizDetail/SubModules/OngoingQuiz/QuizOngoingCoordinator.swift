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
    var finish: Observable<Void>! { get set }
    func openQuizResult()
}

class QuizOngoingCoordinator: BaseCoordinator<Void>, QuizOngoingNavigator {
    let navigationController: UINavigationController
    var finish: Observable<Void>!
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = QuizOngoingController()
        var viewControllers: [UIViewController] = []
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(viewController, animated: true)
        self.navigationController.viewControllers.forEach({ (vc) in
            if vc.isKind(of: PenpolController.self) || vc.isKind(of: QuizOngoingController.self){
                viewControllers.append(vc)
            }
        })
        
        self.navigationController.viewControllers = viewControllers
        finish = PublishSubject<Void>()
        return finish.do(onNext: { (_) in
            
        })
    }
    
    func openQuizResult() {
        
    }
    
    
}
