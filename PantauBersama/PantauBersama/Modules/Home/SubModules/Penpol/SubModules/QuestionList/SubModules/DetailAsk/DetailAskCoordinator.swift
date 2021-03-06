//
//  DetailAskCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Common
import Networking

protocol DetailAskNavigaor {
    var finish: Observable<Void>! { get set }
    func shareQuestion(question: String) -> Observable<Void>
    func launchProfileUser(isMyAccount: Bool, userId: String?) -> Observable<Void>
}

final class DetailAskCoordinator: BaseCoordinator<DetailAskResult> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    private let data: String
    private var isFromNotif: Bool
    
    init(navigationController: UINavigationController, data: String, isFromNotif: Bool) {
        self.navigationController = navigationController
        self.data = data
        self.isFromNotif = isFromNotif
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = DetailAskController()
        let viewModel = DetailAskViewModel(navigator: self, data: data)
        viewController.isFromNotif = isFromNotif
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return viewModel.output.backO
            .asObservable()
            .take(1)
            .do(onNext: { [weak self] (type) in
                print("Type coordination:\(type)")
                self?.navigationController.popViewController(animated: true)
            })
    }
    
}

extension DetailAskCoordinator: DetailAskNavigaor {
    
    func shareQuestion(question: String) -> Observable<Void> {
        // TODO: coordinate to share
        let askString = "Kamu setuju pertanyaan ini? Upvote dulu, dong ⬆️ #PantauBersama \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/tanya/\(question)"
        let activityViewController = UIActivityViewController(activityItems: [askString as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func launchProfileUser(isMyAccount: Bool, userId: String?) -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, isMyAccount: isMyAccount, userId: userId)
        return coordinate(to: profileCoordinator)
    }
}
