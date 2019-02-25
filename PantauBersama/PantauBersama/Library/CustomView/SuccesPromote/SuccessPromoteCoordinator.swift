//
//  SuccessPromoteCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

final class SuccessPromoteCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let viewController: SucceessPromoteView
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.viewController = SucceessPromoteView()
    }
    
    override func start() -> Observable<Void> {
        let viewController = SucceessPromoteView()
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return Observable.empty()
    }
    
}
