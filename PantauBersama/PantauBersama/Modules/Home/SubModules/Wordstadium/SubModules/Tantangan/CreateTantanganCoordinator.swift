//
//  CreateTantanganCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol CreateTantanganNavigator {
    func launchOpen() -> Observable<Void>
    func launchDirect() -> Observable<Void>
    var finish: Observable<Void>! { get set }
}

final class CreateTantanganCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = CreateTantanganViewModel(navigator: self)
        let viewController = CreateTantanganController()
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension CreateTantanganCoordinator: CreateTantanganNavigator {
    func launchOpen() -> Observable<Void> {
        let openCoordinator = TantanganChallengeCoordinator(navigationController: navigationController, type: false)
        return coordinate(to: openCoordinator)
    }
    
    func launchDirect() -> Observable<Void> {
        let openCoordinator = TantanganChallengeCoordinator(navigationController: navigationController, type: true)
        return coordinate(to: openCoordinator)
    }
    
    
}
