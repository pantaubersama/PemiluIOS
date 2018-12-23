//
//  QuizInfoCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift

class QuizInfoCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    override func start() -> Observable<Void> {
        let viewController = QuizInfoController()
        let viewModel = QuizInfoViewModel()
        viewController.viewModel = viewModel
        
        navigationController.present(viewController, animated: true, completion: nil)
        
        return viewModel.output.finish.do(onNext: { [weak self](_) in
            self?.navigationController.dismiss(animated: true, completion: nil)
        }).asObservable()
    }
    
}
