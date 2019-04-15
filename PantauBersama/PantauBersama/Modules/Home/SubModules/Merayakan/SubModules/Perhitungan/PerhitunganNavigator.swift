//
//  PerhitunganNavigator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Networking

protocol PerhitunganNavigator: class {
    var navigationController: UINavigationController! { get }
    func launchPerhitunganDetail() -> Observable<Void>
    func launchCreatePerhitungan() -> Observable<Void>
    func launchDetailTps(realCount: RealCount) -> Observable<Void>
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
    func editTPS(realCount: RealCount) -> Observable<Void>
}

extension PerhitunganNavigator where Self: BaseCoordinator<Void> {
    func launchPerhitunganDetail() -> Observable<Void> {
        return Observable.empty()
    }
    
    func launchCreatePerhitungan() -> Observable<Void> {
        let createPerhitunganCoordinator = CreatePerhitunganCoordinator(navigationController: navigationController, isEdit: false, realCount: nil, isFromDetail: false, isFromSandbox: false)
        return coordinate(to: createPerhitunganCoordinator)
    }
    
    func launchDetailTps(realCount: RealCount) -> Observable<Void> {
        if realCount.status == .sandbox {
            let detailTPSCoordinator = DetailTPSCoordinator(navigationController: navigationController, realCount: realCount, isFromSanbox: true)
            return coordinate(to: detailTPSCoordinator)
        } else {
            let detailTPSCoordinator = DetailTPSCoordinator(navigationController: navigationController, realCount: realCount, isFromSanbox: false)
            return coordinate(to: detailTPSCoordinator)
        }
    }
    
    func editTPS(realCount: RealCount) -> Observable<Void> {
        if realCount.status == .sandbox {
            let createPerhitunganCoordinator = CreatePerhitunganCoordinator(navigationController: navigationController, isEdit: true, realCount: realCount, isFromDetail: false, isFromSandbox: true)
            return coordinate(to: createPerhitunganCoordinator)
        } else {
            let createPerhitunganCoordinator = CreatePerhitunganCoordinator(navigationController: navigationController, isEdit: true, realCount: realCount, isFromDetail: false, isFromSandbox: false)
            return coordinate(to: createPerhitunganCoordinator)
        }
    }
}


