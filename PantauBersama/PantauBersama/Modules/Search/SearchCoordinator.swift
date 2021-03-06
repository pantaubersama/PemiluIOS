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

protocol SearchNavigator: PenpolNavigator, LinimasaNavigator, ClusterSearchNavigator, UserSearchNavigator {
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
    func launchProfileUser(isMyAccount: Bool, userId: String?) -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, isMyAccount: isMyAccount, userId: userId)
        return coordinate(to: profileCoordinator)
    }
    
    func launchProfile(isMyAccount: Bool, userId: String?) -> Observable<Void> {
        return Observable.empty()
    }
    
    
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
    
    func launchNotifications() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchAddJanji() -> Observable<SelectionResult> {
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
            let coordinator = QuizResultCoordinator(navigationController: self.navigationController, quiz: quiz, isFromDeeplink: false, participationURL: nil)
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

    func launchDetailAsk(data: String) -> Observable<DetailAskResult> {
        let detailAskCoordinator = DetailAskCoordinator(navigationController: navigationController, data: data, isFromNotif: false)
        return coordinate(to: detailAskCoordinator)
    }
    
    func lunchClusterDetail(cluster: ClusterDetail) -> Observable<Void> {
        let clusterDetailCoordinator = ClusterDetailCoordinator(navigationController: self.navigationController, cluster: cluster)
        
        return coordinate(to: clusterDetailCoordinator)
    }
}
