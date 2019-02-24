//
//  RekapNavigator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

protocol RekapNavigator: class {
    var navigationController: UINavigationController! { get }
    
    func launchBanner() -> Observable<Void>
}

extension RekapNavigator where Self: BaseCoordinator<Void> {
    func launchBanner() -> Observable<Void> {
        return Observable.empty()
    }
}
