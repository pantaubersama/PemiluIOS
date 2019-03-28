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
    func launchDetailTps(data: RealCount) -> Observable<Void>
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
    
    func launchDetailTps(data: RealCount) -> Observable<Void> {
        let detailTPSCoordinator = DetailTPSCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: detailTPSCoordinator)
    }
}


