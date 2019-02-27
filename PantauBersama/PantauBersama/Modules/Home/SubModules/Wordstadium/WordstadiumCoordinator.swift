//
//  WordstadiumCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 11/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Networking

protocol WordstadiumNavigator {
    func launchProfile(isMyAccount: Bool, userId: String?) -> Observable<Void>
    func launchNotifications() -> Observable<Void>
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
    func launchNote() -> Observable<Void>
    func launchSearch() -> Observable<Void>
    func launchTooltip() -> Observable<TooltipResult>
    func launchWordstadiumList(wordstadium: SectionWordstadium) -> Observable<Void>
    func launchChallenge(wordstadium: Challenge) -> Observable<Void>
    func launchLiveChallenge(wordstadium: Challenge) -> Observable<Void>
}

class WordstadiumCoordinator: BaseCoordinator<Void> {
    
    var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = WordstadiumController()
        let viewModel = WordstadiumViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        return Observable.never()
    }
}

extension WordstadiumCoordinator: WordstadiumNavigator {
    
    func launchProfile(isMyAccount: Bool, userId: String?) -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, isMyAccount: isMyAccount, userId: userId)
        return coordinate(to: profileCoordinator)
    }
    
    func launchNotifications() -> Observable<Void> {
        let notificationCoordinator = NotificationCoordinator(navigationController: navigationController)
        return coordinate(to: notificationCoordinator)
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    func launchNote() -> Observable<Void> {
        let catatanCoordinator = CatatanCoordinator(navigationController: navigationController)
        return coordinate(to: catatanCoordinator)
    }
    
    func launchSearch() -> Observable<Void> {
        let searchCoordinator = SearchCoordinator(navigationController: self.navigationController)
        return coordinate(to: searchCoordinator)
    }
    
    func launchTooltip() -> Observable<TooltipResult> {
        let tooltipCoordinator = TooltipCoordinator(navigationController: navigationController)
        return coordinate(to: tooltipCoordinator)
    }
    
    func launchWordstadiumList(wordstadium: SectionWordstadium) -> Observable<Void> {
        let listCoordinator = WordstadiumListCoordinator(navigationController: navigationController, progressType: wordstadium.itemType, liniType: wordstadium.type)
        return coordinate(to: listCoordinator)
    }
    
    func launchChallenge(wordstadium: Challenge) -> Observable<Void> {
        let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, data: wordstadium)
        return coordinate(to: challengeCoordinator)
    }
    
    func launchLiveChallenge(wordstadium: Challenge) -> Observable<Void> {
        let liveDebatCoordinator = LiveDebatCoordinator(navigationController: navigationController, viewType: .watch)
        return coordinate(to: liveDebatCoordinator)
    }
}
