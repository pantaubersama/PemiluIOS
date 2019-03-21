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
    func launchDetailTps() -> Observable<Void>
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
}

extension PerhitunganNavigator where Self: BaseCoordinator<Void> {
    func launchPerhitunganDetail() -> Observable<Void> {
        return Observable.empty()
    }
    
    func launchCreatePerhitungan() -> Observable<Void> {
        let createPerhitunganCoordinator = CreatePerhitunganCoordinator(navigationController: navigationController)
        return coordinate(to: createPerhitunganCoordinator)
    }
    
    func launchDetailTps() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
}


