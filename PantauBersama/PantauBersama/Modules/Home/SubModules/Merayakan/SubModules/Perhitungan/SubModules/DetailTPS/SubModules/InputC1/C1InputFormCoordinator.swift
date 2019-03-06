//
//  InputC1Coordinator.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa

protocol C1InputFormNavigator {
    func back() -> Observable<Void>
}

class C1InputFormCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let type: FormC1Type
    
    init(navigationController: UINavigationController, type: FormC1Type) {
        self.type = type
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = C1InputFormController()
        let viewModel = C1InputFormViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        viewController.type = type
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension C1InputFormCoordinator: C1InputFormNavigator {
    func back() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        return Observable.empty()
    }
}
