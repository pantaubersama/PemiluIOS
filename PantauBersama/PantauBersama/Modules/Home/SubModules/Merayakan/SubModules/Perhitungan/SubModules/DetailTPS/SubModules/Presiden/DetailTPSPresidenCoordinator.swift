//
//  HitungSuaraPresidenCoordinator.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 02/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

protocol DetailTPSPresidenNavigator {
    func back() -> Observable<Void>
}

class DetailTPSPresidenCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let uuid: String
    
    init(navigationController: UINavigationController, uuid: String) {
        self.navigationController = navigationController
        self.uuid = uuid
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailTPSPresidenController()
        let viewModel = DetailTPSPresidenViewModel(navigator: self, uuid: self.uuid)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension DetailTPSPresidenCoordinator: DetailTPSPresidenNavigator {
    func back() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        return Observable.empty()
    }
}
