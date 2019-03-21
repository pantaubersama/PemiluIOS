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

protocol DetailTPSPresidenNavigator {
    func back() -> Observable<Void>
    func launchDetailTPS() -> Observable<Void>
}

class DetailTPSPresidenCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailTPSPresidenController()
        let viewModel = DetailTPSPresidenViewModel(navigator: self)
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
    
    func launchDetailTPS() -> Observable<Void> {
        let detailTPSCoordinator = DetailTPSCoordinator(navigationController: self.navigationController)
        return coordinate(to: detailTPSCoordinator)
    }
}

