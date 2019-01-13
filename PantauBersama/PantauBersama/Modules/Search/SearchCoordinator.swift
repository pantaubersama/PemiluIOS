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

protocol SearchNavigator: PenpolNavigator {
    
}

class SearchCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private(set) var internalNavigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = SearchController()
        let viewModel = SearchViewModel(navigator: self)
        viewController.viewModel = viewModel
        
        internalNavigationController = UINavigationController(rootViewController: viewController)
        navigationController.present(internalNavigationController, animated: true, completion: nil)
        
        return Observable.never()
    }
}

extension SearchCoordinator: SearchNavigator {
    func launchFilter(filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) -> Observable<Void> {
        return Observable.never()
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
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
