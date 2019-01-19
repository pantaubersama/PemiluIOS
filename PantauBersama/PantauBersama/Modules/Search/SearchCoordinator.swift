//
//  SearchCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 13/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

protocol SearchNavigator: PenpolNavigator, LinimasaNavigator {
    func finishSearch() -> Observable<Void>
}

class SearchCoordinator: BaseCoordinator<Void> {

    private let externalNavigationController: UINavigationController
    
    private var filterCoordinator: PenpolFilterCoordinator!
    
    var navigationController: UINavigationController! {
        return externalNavigationController
    }
    
    init(navigationController: UINavigationController) {
        self.externalNavigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = SearchController()
        let viewModel = SearchViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        
        return Observable.never()
    }
}

extension SearchCoordinator: SearchNavigator {
    
    func launchUpdates(type: TypeUpdates) -> Observable<Void> {
        let updatesView = UpdatesCoordinator(navigationController: navigationController, type: type)
        return coordinate(to: updatesView)
    }
    
    func launcWebView(link: String) -> Observable<Void> {
        let wkwebCoordinator = WKWebCoordinator(navigationController: navigationController, url: link)
        return coordinate(to: wkwebCoordinator)
    }
    
    func launchPenpolBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        return Observable.never()
    }
    
    func launchProfile() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchNotifications() {
        
    }
    
    func launchAddJanji() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchNote() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchSearch() -> Observable<Void> {
        return Observable.never()
    }
    
    func sharePilpres(data: Any) -> Observable<Void> {
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
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
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        return Observable.never()
    }
    
    func finishSearch() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.never()
    }
    
    func launchFilter(filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) -> Observable<Void> {
        if filterCoordinator == nil {
            filterCoordinator = PenpolFilterCoordinator(navigationController: self.navigationController, filterType: filterType, filterTrigger: filterTrigger)
        }
        
        filterCoordinator.filterType = filterType
        
        return coordinate(to: filterCoordinator)
    }
    
    func openQuiz(quiz: QuizModel) -> Observable<Void> {
        return Observable.never()
    }
    
    func shareQuiz(quiz: QuizModel) -> Observable<Void> {
        return Observable.never()
    }
    
    func shareTrend(trend: Any) -> Observable<Void> {
        return Observable.never()
    }
    
    func launchCreateAsk() -> Observable<Void> {
        return Observable.never()
    }
    
    func shareQuestion(question: String) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: [question as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }

    
    
}
