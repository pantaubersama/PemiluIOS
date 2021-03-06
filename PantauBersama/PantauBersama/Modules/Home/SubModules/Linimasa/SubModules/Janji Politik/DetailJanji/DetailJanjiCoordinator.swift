//
//  DetailJanjiCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common
import FBSDKCoreKit

protocol DetailJanjiNavigator {
    func shareJanji(data: JanjiPolitik) -> Observable<Void>
    func close()
    func launchProfileUser(isMyAccount: Bool, userId: String?) -> Observable<Void>
    func launchClusterDetail(cluster: ClusterDetail) -> Observable<Void>
}

class DetailJanjiCoordinator: BaseCoordinator<DetailJanpolResult> {
    
    private let navigationController: UINavigationController!
    private let data: String
    
    init(navigationController: UINavigationController, data: String) {
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() -> Observable<CoordinationResult> {
        FBSDKAppEvents.logEvent("Detail Janji", parameters: ["content_id": data])
        let viewController = DetailJanjiController()
        let viewModel = DetailJanjiViewModel(navigator: self, data: data)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return viewModel.output.closeSelected.asObservable()
            .take(1)
    }
    
}

extension DetailJanjiCoordinator: DetailJanjiNavigator {
    func close() {
        guard let viewController = navigationController.viewControllers.first else {
            return
        }
        navigationController.popToViewController(viewController, animated: true)
    }
    
    func shareJanji(data: JanjiPolitik) -> Observable<Void> {
        let share = "Sudah tahu Janji yang ini, belum? Siap-siap catatan, ya! ✔️ #PantauBersama \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/janjipolitik/\(data.id)"
        let activityViewController = UIActivityViewController(activityItems: [share as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func launchProfileUser(isMyAccount: Bool, userId: String?) -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, isMyAccount: isMyAccount, userId: userId)
        return coordinate(to: profileCoordinator)
    }

    func launchClusterDetail(cluster: ClusterDetail) -> Observable<Void> {
        let clusterDetailCoordinator = ClusterDetailCoordinator(navigationController: navigationController, cluster: cluster)
        return coordinate(to: clusterDetailCoordinator)
    }
}
