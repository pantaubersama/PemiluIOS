//
//  OpenChallengeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol OpenChallengeNavigator {
    var finish: Observable<Void>! { get set }
}

final class OpenChallengeCoordinator: BaseCoordinator<Void>, OpenChallengeNavigator {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = OpenChallengeViewModel(navigator: self)
        let viewController = OpenChallengeController()
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}
