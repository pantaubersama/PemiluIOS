//
//  RekapListTPSNavigator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol RekapListTPSNavigator {
    func back() -> Observable<Void>
}

final class RekapListTPSCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let villageId: Int
    private let villageName: String
    
    init(navigationController: UINavigationController, villageId: Int, villageName: String) {
        self.navigationController = navigationController
        self.villageId = villageId
        self.villageName = villageName
    }
    
    override func start() -> Observable<Void> {
        let viewModel = RekapListTPSViewModel(navigator: self, villageId: self.villageId, villageName: self.villageName)
        let viewController = RekapListTPSController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
}

extension RekapListTPSCoordinator: RekapListTPSNavigator {
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
}
