//
//  DetailTPSDPDCoordinator.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa

protocol DetailTPSDPDNavigator {
    func back() -> Observable<Void>
}

class DetailTPSDPDCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailTPSDPDController()
        let viewModel = DetailTPSDPDViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension DetailTPSDPDCoordinator: DetailTPSDPDNavigator {
    func back() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        return Observable.empty()
    }
}
