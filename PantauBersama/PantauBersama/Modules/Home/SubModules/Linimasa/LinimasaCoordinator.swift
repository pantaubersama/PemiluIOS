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

enum TypeUpdates {
    case minor
    case major
}

protocol LinimasaNavigator: PilpresNavigator, IJanpolNavigator {
    func launchProfile(isMyAccount: Bool, userId: String?) -> Observable<Void>
    func launchNotifications() -> Observable<Void>
    func launchAddJanji() -> Observable<Void>
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
    func launchNote() -> Observable<Void>
    func launchFilter(filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) -> Observable<Void>
    func launchSearch() -> Observable<Void>
    func launcWebView(link: String) -> Observable<Void>
    func launchUpdates(type: TypeUpdates) -> Observable<Void>
}

class LinimasaCoordinator: BaseCoordinator<Void> {
    
    var navigationController: UINavigationController!
    private var filterCoordinator: PenpolFilterCoordinator!

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
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<Void> {
        let janjiDetailCoordinator = DetailJanjiCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: janjiDetailCoordinator)
    }
    
    func launchSearch() -> Observable<Void> {
        let searchCoordinator = SearchCoordinator(navigationController: self.navigationController)
        return coordinate(to: searchCoordinator)
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    func launchFilter(filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) -> Observable<Void> {
        if filterCoordinator == nil {
            filterCoordinator = PenpolFilterCoordinator(navigationController: navigationController)
        }
        
        filterCoordinator.filterType = filterType
        filterCoordinator.filterTrigger = filterTrigger
        
        return coordinate(to: filterCoordinator)
    }
    
    func launchAddJanji() -> Observable<Void> {
        let janjiCoordinator = CreateJanjCoordinator(navigationController: navigationController)
        return coordinate(to: janjiCoordinator)
    }
    
    
    func launchProfile(isMyAccount: Bool, userId: String?) -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, isMyAccount: isMyAccount, userId: userId)
        return coordinate(to: profileCoordinator)
    }
    
    func launchNotifications() -> Observable<Void> {
        let notificationCoordinator = NotificationCoordinator(navigationController: navigationController)
        return coordinate(to: notificationCoordinator)
    }
    
    func launchNote() -> Observable<Void> {
        let catatanCoordinator = CatatanCoordinator(navigationController: navigationController)
        return coordinate(to: catatanCoordinator)
    }
    
    
    func openTwitter(data: String) -> Observable<Void> {
        if (UIApplication.shared.canOpenURL(URL(string:"twitter://")!)) {
            print("Twitter is installed")
            UIApplication.shared.open(URL(string: "twitter://status?id=\(data)")!, options: [:], completionHandler: nil)
        } else {
            return Observable<Void>.create({ [weak self] (observer) -> Disposable in
                let alert = UIAlertController(title: nil, message: "Anda tidak memiliki aplikasi Twitter", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    observer.onCompleted()
                }))
                DispatchQueue.main.async {
                    self?.navigationController.present(alert, animated: true, completion: nil)
                }
                return Disposables.create()
            })
        }
        return Observable.just(())
    }
    
    
    func sharePilpres(data: Any) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func launcWebView(link: String) -> Observable<Void> {
        let wkwebCoordinator = WKWebCoordinator(navigationController: navigationController, url: link)
        return coordinate(to: wkwebCoordinator)
    }
    
    func launchUpdates(type: TypeUpdates) -> Observable<Void> {
        let updatesView = UpdatesCoordinator(navigationController: navigationController, type: type)
        return coordinate(to: updatesView)
    }
    
}
