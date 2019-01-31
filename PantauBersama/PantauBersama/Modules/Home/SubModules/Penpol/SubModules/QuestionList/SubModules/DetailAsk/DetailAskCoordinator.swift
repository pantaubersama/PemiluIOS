//
//  DetailAskCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Common

protocol DetailAskNavigaor {
    var finish: Observable<Void>! { get set }
    func shareQuestion(question: String) -> Observable<Void>
    func launchProfileUser(isMyAccount: Bool, userId: String?) -> Observable<Void>
}

final class DetailAskCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    private let data: String
    
    init(navigationController: UINavigationController, data: String) {
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailAskController()
        let viewModel = DetailAskViewModel(navigator: self, data: data)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension DetailAskCoordinator: DetailAskNavigaor {
    
    func shareQuestion(question: String) -> Observable<Void> {
        // TODO: coordinate to share
        let askString = "Kamu setuju pertanyaan ini? Upvote dulu, dong ⬆️ #PantauBersama \(AppContext.instance.infoForKey("URL_WEB"))/share/tanya/\(question)"
        let activityViewController = UIActivityViewController(activityItems: [askString as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func launchProfileUser(isMyAccount: Bool, userId: String?) -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, isMyAccount: isMyAccount, userId: userId)
        return coordinate(to: profileCoordinator)
    }
}
