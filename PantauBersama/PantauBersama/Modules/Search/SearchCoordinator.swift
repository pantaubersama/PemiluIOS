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

    private(set) var internalNavigationController: UINavigationController!
    
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
        
        internalNavigationController = UINavigationController(rootViewController: viewController)
        internalNavigationController.modalTransitionStyle = .crossDissolve
        navigationController.present(internalNavigationController, animated: true, completion: nil)
        
        return Observable.never()
    }
}

extension SearchCoordinator: SearchNavigator {
    func launcWebView(link: String) -> Observable<Void> {
        return Observable.never()
    }
    
    func launchPenpolBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        return Observable.never()
    }
    
    func launchProfile() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchNotifications() {
        
    }
    
    func launchFilter() -> Observable<Void> {
        return Observable.never()
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
        return Observable.never()
    }
    
    func openTwitter(data: String) -> Observable<Void> {
        return Observable.never()
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        return Observable.never()
    }
    
    func finishSearch() -> Observable<Void> {
        externalNavigationController.dismiss(animated: true, completion: nil)
        return Observable.never()
    }
    
    func launchFilter(filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) -> Observable<Void> {
        return Observable.never()
    }
    
    func openQuiz(quiz: QuizModel) -> Observable<Void> {
        return Observable.never()
    }
    
    func shareQuiz(quiz: Any) -> Observable<Void> {
        return Observable.never()
    }
    
    func shareTrend(trend: Any) -> Observable<Void> {
        return Observable.never()
    }
    
    func launchCreateAsk() -> Observable<Void> {
        return Observable.never()
    }
    
    func shareQuestion(question: String) -> Observable<Void> {
        return Observable.never()
    }

    
    
}
