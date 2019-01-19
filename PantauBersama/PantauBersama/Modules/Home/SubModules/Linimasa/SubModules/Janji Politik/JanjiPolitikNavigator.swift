//
//  JanjiPolitikNavigator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Networking
import Common

protocol IJanpolNavigator: class {
    var navigationController: UINavigationController! { get }
    
    func shareJanji(data: JanjiPolitik) -> Observable<Void>
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<Void>
    func launchJanpolBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
}

extension IJanpolNavigator where Self: BaseCoordinator<Void> {
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<Void> {
        let janjiDetailCoordinator = DetailJanjiCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: janjiDetailCoordinator)
    }
    
    func shareJanji(data: JanjiPolitik) -> Observable<Void> {
        let share = "Sudah tahu Janji yang ini, belum? Siap-siap catatan, ya! ✔️ \(AppContext.instance.infoForKey("URL_API_PEMILU"))/share/janjipolitik/\(data.id)"
        let activityViewController = UIActivityViewController(activityItems: [share as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func launchJanpolBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
}
