//
//  SuccessPromoteCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift


protocol SuccessPromoteNavigator {
    func dismiss() -> Observable<Void>
}

final class SuccessPromoteCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let viewController: SuccessPromoteView
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.viewController = SuccessPromoteView()
    }
    
    override func start() -> Observable<Void> {
        let viewModel = SuccessPromoteViewModel(navigator: self)
        let viewController = SuccessPromoteView()
        viewController.viewModel = viewModel
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return Observable.empty()
    }
    
}

extension SuccessPromoteCoordinator: SuccessPromoteNavigator {
    func dismiss() -> Observable<Void> {
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.navigationController.popToRootViewController(animated: true)
        }
        return Observable.empty()
    }
}
