//
//  ParserCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 29/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import UIKit
import Common
import Networking
import RxSwift

class ParserCoordinator: BaseCoordinator<Void> {
    
    private var navigationController: UINavigationController
    private let notifType: NotifType
    private let link: String?
    
    init(navigationController: UINavigationController, notifType: NotifType, link: String? = nil) {
        self.navigationController = navigationController
        self.notifType = notifType
        self.link = link
    }
    
    override func start() -> Observable<CoordinationResult> {
        switch (notifType) {
        case (.broadcasts):
            if let link = link {
                if link.isValidURL == true {
                    print("NOTIF: ", notifType)
                    let wkwebCoordinator = WKWebCoordinator(navigationController: navigationController, url: link)
                    return coordinate(to: wkwebCoordinator)
                } else {
                    print("INVALID LINK")
                }
            }
            return Observable.empty()
        default:
            return Observable.empty()
        }
    }
}
