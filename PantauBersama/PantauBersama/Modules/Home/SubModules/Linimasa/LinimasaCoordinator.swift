//
//  LinimasaCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Networking

protocol LinimasaNavigator: PilpresNavigator, JanjiPolitikNavigator {
    func launchProfile() -> Observable<Void>
    func launchNotifications()
    func launchFilter() -> Observable<Void>
    func launchAddJanji() -> Observable<Void>
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
    func launchNote() -> Observable<Void>
}

class LinimasaCoordinator: BaseCoordinator<Void> {
    
    var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = LinimasaController()
        let viewModel = LinimasaViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        return Observable.never()
    }
}

extension LinimasaCoordinator: LinimasaNavigator {
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    func launchFilter() -> Observable<Void> {
        let filterCoordinator = FilterCoordinator(navigationController: navigationController)
        return coordinate(to: filterCoordinator)
    }
    
    func launchAddJanji() -> Observable<Void> {
        let janjiCoordinator = CreateJanjCoordinator(navigationController: navigationController)
        return coordinate(to: janjiCoordinator)
    }
    
    
    func launchProfile() -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController)
        return coordinate(to: profileCoordinator)
    }
    
    func launchNotifications() {
        
    }
    
    func launchNote() -> Observable<Void> {
        let catatanCoordinator = CatatanCoordinator(navigationController: navigationController)
        return coordinate(to: catatanCoordinator)
    }
    
}

extension LinimasaCoordinator: PilpresNavigator {
    
    func openTwitter(data: String) -> Observable<Void> {
        UIApplication.shared.open(URL(string: "https://twitter.com/hanif_sgy")!, options: [:], completionHandler: nil)
        return Observable.just(())
    }
    
    
    func sharePilpres(data: Any) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    
}


extension LinimasaCoordinator: JanjiPolitikNavigator {
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<Void> {
        let janjiDetailCoordinator = DetailJanjiCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: janjiDetailCoordinator)
    }
    
    func shareJanji(data: Any) -> Observable<Void> {
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
}
