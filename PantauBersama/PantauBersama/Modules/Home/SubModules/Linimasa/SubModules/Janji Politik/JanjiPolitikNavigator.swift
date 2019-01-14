//
//  JanjiPolitikNavigator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Networking

protocol IJanpolNavigator: class {
    var navigationController: UINavigationController! { get }
    
    func shareJanji(data: Any) -> Observable<Void>
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<Void>
    func launchJanpolBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
}

extension IJanpolNavigator where Self: BaseCoordinator<Void> {
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<Void> {
        let janjiDetailCoordinator = DetailJanjiCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: janjiDetailCoordinator)
    }
    
    func shareJanji(data: Any) -> Observable<Void> {
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func launchJanpolBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
}
