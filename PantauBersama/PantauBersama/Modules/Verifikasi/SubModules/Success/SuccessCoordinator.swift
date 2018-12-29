//
//  SuccessCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 30/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxCocoa
import RxSwift

protocol SuccessNavigator {
    func finish()
}

class SuccessCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = SuccessViewModel(navigator: self)
        let viewController = SuccessController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension SuccessCoordinator: SuccessNavigator {
    func finish() {
        guard let viewController = navigationController.viewControllers.first else {
            return
        }
        navigationController.popToViewController(viewController, animated: true)
    }
}
