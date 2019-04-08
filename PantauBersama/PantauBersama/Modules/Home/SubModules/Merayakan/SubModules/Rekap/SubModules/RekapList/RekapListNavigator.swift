//
//  RekapListNavigator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Networking

protocol RekapListNavigator {
    func back() -> Observable<Void>
    func launchDetail(item: Region) -> Observable<Void>
    func launchDetailVillage(data: Int) -> Observable<Void>
}

final class RekapListCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let region: Region
    
    init(navigationController: UINavigationController, region: Region) {
        self.navigationController = navigationController
        self.region = region
    }
    
    override func start() -> Observable<Void> {
        let viewModel = RekapListViewModel(navigator: self, region: self.region)
        let viewController = RekapListController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}


extension RekapListCoordinator: RekapListNavigator {
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    
    func launchDetail(item: Region) -> Observable<Void> {
        let listRekap = RekapListCoordinator(navigationController: navigationController, region: item)
        return coordinate(to: listRekap)
    }
    
    func launchDetailVillage(data: Int) -> Observable<Void> {
        let listVillage = RekapListVillageCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: listVillage)
    }
}
