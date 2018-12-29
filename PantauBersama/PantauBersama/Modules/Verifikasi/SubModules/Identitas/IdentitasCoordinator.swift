//
//  IdentitasCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol IdentitasNavigator {
    var finish: Observable<Void>! { get set }
    func launchSelfIdentitas() -> Observable<Void>
}

class IdentitasCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = IdentitasController()
        let viewModel = IdentitasViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
}

extension IdentitasCoordinator: IdentitasNavigator {
    
    func launchSelfIdentitas() -> Observable<Void> {
        let selfIdentitasCoordinator = SelfIdentitasCoordinator(navigationController: navigationController)
        return coordinate(to: selfIdentitasCoordinator)
    }
}
