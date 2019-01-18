//
//  UpdatesCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol UpdatesNavigator {
    func nextTime() -> Observable<Void>
    func update()
}

final class UpdatesCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let updatesType: TypeUpdates
    
    init(navigationController: UINavigationController, type: TypeUpdates) {
        self.navigationController = navigationController
        self.updatesType = type
    }
    
    override func start() -> Observable<Void> {
        let viewModel = UpdatesViewModel(navigator: self, type: updatesType)
        let viewController = UpdatesView()
        viewController.viewModel = viewModel
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return Observable.never()
    }
    
}

extension UpdatesCoordinator: UpdatesNavigator {
    
    func nextTime() -> Observable<Void> {
        return Observable.empty()
    }
    
    func update() {
        
    }
}
