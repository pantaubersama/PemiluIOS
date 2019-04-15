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
    private let isFromSandbox: Bool
    
    init(navigationController: UINavigationController, isEdit: Bool, realCount: RealCount?, isFromDetail: Bool, isFromSandbox: Bool) {
        self.navigationController = navigationController
        self.isEdit = isEdit
        self.realCount = realCount
        self.isFromDetail = isFromDetail
        self.isFromSandbox = isFromSandbox
    }
    
    override func start() -> Observable<Void> {
        let viewController = CreatePerhitunganController()
        viewController.isSanbox = self.isFromSandbox
        let viewModel = CreatePerhitunganViewModel(navigator: self, data: self.realCount, isEdit: self.isEdit, isFromSanbox: isFromDetail)
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
        if realCount.status == .sandbox {
            let detailTPSCoordinator = DetailTPSCoordinator(navigationController: self.navigationController, realCount: realCount, isFromSanbox: true)
            return coordinate(to: detailTPSCoordinator)
        } else {
            let detailTPSCoordinator = DetailTPSCoordinator(navigationController: self.navigationController, realCount: realCount, isFromSanbox: false)
            return coordinate(to: detailTPSCoordinator)
        }
    }
}
