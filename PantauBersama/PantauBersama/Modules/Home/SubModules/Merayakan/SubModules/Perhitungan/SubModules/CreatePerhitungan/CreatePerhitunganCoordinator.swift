//
//  CreatePerhitunganCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

protocol CreatePerhitunganNavigator {
    func back() -> Observable<Void>
    func launchDetailTPS(realCount: RealCount) -> Observable<Void>
}

class CreatePerhitunganCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let isEdit: Bool
    private let realCount: RealCount?
    private let isFromDetail: Bool
    
    init(navigationController: UINavigationController, isEdit: Bool, realCount: RealCount?, isFromDetail: Bool) {
        self.navigationController = navigationController
        self.isEdit = isEdit
        self.realCount = realCount
        self.isFromDetail = isFromDetail
    }
    
    override func start() -> Observable<Void> {
        let viewController = CreatePerhitunganController()
        let viewModel = CreatePerhitunganViewModel(navigator: self, data: self.realCount, isEdit: self.isEdit)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension CreatePerhitunganCoordinator: CreatePerhitunganNavigator {
    func back() -> Observable<Void> {
        if self.isFromDetail == true {
            self.navigationController.popToRootViewController(animated: true)
        } else {
            self.navigationController.popViewController(animated: true)
        }
        return Observable.empty()
    }
    
    func launchDetailTPS(realCount: RealCount) -> Observable<Void> {
        let detailTPSCoordinator = DetailTPSCoordinator(navigationController: self.navigationController, realCount: realCount)
        return coordinate(to: detailTPSCoordinator)
    }
}
