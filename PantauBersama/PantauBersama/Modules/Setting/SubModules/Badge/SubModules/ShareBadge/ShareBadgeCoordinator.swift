//
//  ShareBadgeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol ShareBadgeNavigator {
    var finish: Observable<Void>! { get set }
}

final class ShareBadgeCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    var finish: Observable<Void>!
    var id: String
    
    init(navigationController: UINavigationController, id: String) {
        self.navigationController = navigationController
        self.id = id
    }
    
    override func start() -> Observable<Void> {
        let viewController = ShareBadgeController()
        let viewModel = ShareBadgeViewModel(navigator: self, id: id)
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension ShareBadgeCoordinator: ShareBadgeNavigator {
    
}
