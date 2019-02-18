//
//  ChallengeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol ChallengeNavigator {
    func back() -> Observable<Void>
}

final class ChallengeCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private var type: ChallengeType = .default
    
    init(navigationController: UINavigationController, type: ChallengeType) {
        self.navigationController = navigationController
        self.type = type
    }
    
    override func start() -> Observable<Void> {
        let viewController = ChallengeController()
        let viewModel = ChallengeViewModel(navigator: self, type: type)
        viewController.type = type
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension ChallengeCoordinator: ChallengeNavigator {
    
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    
}
