//
//  CreatePerhitunganCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

protocol CreatePerhitunganNavigator {
    func back() -> Observable<Void>
}

class CreatePerhitunganCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = CreatePerhitunganController()
        let viewModel = CreatePerhitunganViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension CreatePerhitunganCoordinator: CreatePerhitunganNavigator {
    func back() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        return Observable.empty()
    }
}
