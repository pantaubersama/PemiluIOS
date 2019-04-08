//
//  RekapListVillageNavigator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Networking

protocol RekapListVillageNavigator {
    func back() -> Observable<Void>
    func launchDetail() -> Observable<Void>
}

final class RekapListVillageCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let data: Int
    
    init(navigationController: UINavigationController, data: Int) {
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() -> Observable<Void> {
        let viewModel = RekapListVillageViewModel(navigator: self, data: self.data)
        let viewController = RekapListVillageController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension RekapListVillageCoordinator: RekapListVillageNavigator {
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    func launchDetail() -> Observable<Void> {
        return Observable.empty()
    }
}
