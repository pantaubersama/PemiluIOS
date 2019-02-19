//
//  DebatDetailCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 18/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

protocol DebatDetailNavigator {
    func back() -> Observable<Void>
}

class DebatDetailCoordinator: BaseCoordinator<Void> {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = DebatDetailController()
        let viewModel = DebatDetailViewModel(navigator: self)
        viewController.viewModel = viewModel
        
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return Observable.never()
    }
}

extension DebatDetailCoordinator: DebatDetailNavigator {
    func back() -> Observable<Void> {
        self.navigationController.dismiss(animated: true
            , completion: nil)
        return Observable.never()
    }
}
