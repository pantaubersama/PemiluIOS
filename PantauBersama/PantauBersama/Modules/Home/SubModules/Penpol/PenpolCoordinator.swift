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
import FBSDKCoreKit

protocol PenpolNavigator: QuizNavigator, IQuestionNavigator {
    func launchFilter(filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) -> Observable<Void>
    func launchPenpolBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
    func launchSearch() -> Observable<Void>
    func launchNote() -> Observable<Void>
    func launchProfile(isMyAccount: Bool, userId: String?) -> Observable<Void>
    func launchDetailAsk(data: String) -> Observable<DetailAskResult>
    func launchNotifications() -> Observable<Void>
}

class PenpolCoordinator: BaseCoordinator<Void> {
    
    internal let navigationController: UINavigationController!
    private var filterCoordinator: PenpolFilterCoordinator!
    private var isNewQuiz: Bool = false
    
    init(navigationController: UINavigationController, isNewQuiz: Bool = false) {
        self.navigationController = navigationController
        self.isNewQuiz = isNewQuiz
    }
    
    override func start() -> Observable<CoordinationResult> {
        FBSDKAppEvents.logEvent("Pendidikan Politik")
        let viewController = PenpolController()
        let viewModel = PenpolViewModel(navigator: self)
        viewController.isNewQuiz = self.isNewQuiz
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        return Observable.never()
    }
}

extension PenpolCoordinator: PenpolNavigator {

    func launchSearch() -> Observable<Void> {
        let searchCoordinator = SearchCoordinator(navigationController: self.navigationController)
        return coordinate(to: searchCoordinator)
    }
    
    func launchFilter(filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) -> Observable<Void> {
//        let filterCoordinator = FilterCoordinator(navigationController: self.navigationController)
//        return coordinate(to: filterCoordinator)
        
        if filterCoordinator == nil {
            filterCoordinator = PenpolFilterCoordinator(navigationController: self.navigationController)
        }
        
        filterCoordinator.filterType = filterType
        filterCoordinator.filterTrigger = filterTrigger
        
        return coordinate(to: filterCoordinator)
    }
    
    func openQuiz(quiz: QuizModel) -> Observable<Void> {
        if !PantauAuthAPI.isLoggedIn {
            let alert = UIAlertController(title: "Perhatian", message: "Sesi Anda telah berakhir, silahkan login terlebih dahulu", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .destructive, handler: { (_) in
                KeychainService.remove(type: NetworkKeychainKind.token)
                KeychainService.remove(type: NetworkKeychainKind.refreshToken)
                // need improve this later
                // todo using wkwbview or using another framework to handle auth
                var appCoordinator: AppCoordinator!
                let disposeBag = DisposeBag()
                var window: UIWindow?
                window = UIWindow()
                appCoordinator = AppCoordinator(window: window!)
                appCoordinator.start()
                    .subscribe()
                    .disposed(by: disposeBag)
                
            }))
            alert.show()
            
            return Observable.never()
        }
        
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
    
    func shareQuiz(quiz: QuizModel) -> Observable<Void> {
        // TODO: coordinate to share
        let share = "Iseng-iseng serius main Quiz ini dulu. Kira-kira masih cocok apa ternyata malah nggak cocok, yaa 😶 #PantauBersama \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/kuis/\(quiz.id)"
        let activityViewController = UIActivityViewController(activityItems: [share as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func shareTrend() -> Observable<Void> {
        // TODO: coordinate to share
        let trendCoordinator = ShareTrendCoordinator(navigationController: navigationController)
        return coordinate(to: trendCoordinator)
    }
    
    func launchPenpolBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    func launchNote() -> Observable<Void> {
        let catatanCoordinator = CatatanCoordinator(navigationController: navigationController)
        return coordinate(to: catatanCoordinator)
    }
    
    func launchProfile(isMyAccount: Bool, userId: String?) -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, isMyAccount: isMyAccount, userId: userId)
        return coordinate(to: profileCoordinator)
    }
    
    func launchDetailAsk(data: String) -> Observable<DetailAskResult> {
        let detailAskCoordinator = DetailAskCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: detailAskCoordinator)
    }
    
    func launchNotifications() -> Observable<Void> {
        let notificationCoordinator = NotificationCoordinator(navigationController: navigationController)
        return coordinate(to: notificationCoordinator)
    }
}
