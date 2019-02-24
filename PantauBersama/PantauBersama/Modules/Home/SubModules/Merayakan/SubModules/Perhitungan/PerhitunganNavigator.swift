//
//  PerhitunganNavigator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

protocol PerhitunganNavigator: class {
    var navigationController: UINavigationController! { get }
    func openPerhitunganDetail() -> Observable<Void>
}

extension PerhitunganNavigator where Self: BaseCoordinator<Void> {
    func openPerhitunganDetail() -> Observable<Void> {
        return Observable.empty()
    }
}


