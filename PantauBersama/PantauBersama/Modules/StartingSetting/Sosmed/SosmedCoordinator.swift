//
//  SosmedCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol SosmedNavigator {
    var finish: Observable<Void>! { get set }
}

final class SosmedCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = SosmedViewModel(navigator: self)
        let viewController = SosmedController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension SosmedCoordinator: SosmedNavigator {
}
