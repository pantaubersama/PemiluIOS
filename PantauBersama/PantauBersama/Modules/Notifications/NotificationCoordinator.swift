//
//  NotificationCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking


protocol NotificationNavigator {
    func back() -> Observable<Void>
    func openQuestion(questionId: String) -> Observable<Void>
    func openShareBadge(badge: NotifBadge) -> Observable<Void>
    func openQuizPage() -> Observable<Void>
}

final class NotificationCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = NotificationViewModel(navigator: self)
        let viewController = NotificationController()
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension NotificationCoordinator: NotificationNavigator {
    
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    
    func openQuestion(questionId: String) -> Observable<Void> {
        let questionDetailCoorinator = DetailAskCoordinator(navigationController: self.navigationController, data: questionId, isFromNotif: false)
        return coordinate(to: questionDetailCoorinator).mapToVoid()
    }
    
    func openShareBadge(badge: NotifBadge) -> Observable<Void> {
        let shareBadgeCoordinator = ShareBadgeCoordinator(navigationController: self.navigationController, id: badge.id)
        
        return coordinate(to: shareBadgeCoordinator)
    }
    
    func openQuizPage() -> Observable<Void> {
        if let appWindow = UIApplication.shared.keyWindow {
            let homeCoordinator = HomeCoordinator(window: appWindow, isNewQuiz: true)
            
            return coordinate(to: homeCoordinator)
        }
        return Observable.never()
    }
    
}
