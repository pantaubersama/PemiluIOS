//
//  PenpolCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Common
import Networking

protocol PenpolNavigator: QuizNavigator, IQuestionNavigator {
    func launchFilter(filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) -> Observable<Void>
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
}

class PenpolCoordinator: BaseCoordinator<Void> {
    
    internal let navigationController: UINavigationController!
    private var filterCoordinator: PenpolFilterCoordinator!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = PenpolController()
        let viewModel = PenpolViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        return Observable.never()
    }
}

extension PenpolCoordinator: PenpolNavigator {

    func launchFilter(filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) -> Observable<Void> {
//        let filterCoordinator = FilterCoordinator(navigationController: self.navigationController)
//        return coordinate(to: filterCoordinator)
        
        if filterCoordinator == nil {
            filterCoordinator = PenpolFilterCoordinator(navigationController: self.navigationController, filterType: filterType, filterTrigger: filterTrigger)
        }
        
        filterCoordinator.filterType = filterType
        
        return coordinate(to: filterCoordinator)
    }
    
    func launchCreateAsk() -> Observable<Void> {
        let createAskCoordinator = CreateAskCoordinator(navigationController: self.navigationController)
        return coordinate(to: createAskCoordinator)
    }
    
    func shareQuestion(question: String) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: [question as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func openQuiz(quiz: QuizModel) -> Observable<Void> {
        switch quiz.participationStatus {
        case .inProgress:
            let coordinator = QuizOngoingCoordinator(navigationController: self.navigationController, quiz: quiz)
            return coordinate(to: coordinator)
        case .finished:
            let coordinator = QuizResultCoordinator(navigationController: self.navigationController, quiz: quiz)
            return coordinate(to: coordinator)
        case .notParticipating:
            let coordinator = QuizDetailCoordinator(navigationController: self.navigationController, quizModel: quiz)
            return coordinate(to: coordinator)
        }
    }
    
    func shareQuiz(quiz: Any) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func shareTrend(trend: Any) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
}
