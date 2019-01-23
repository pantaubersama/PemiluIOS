
//
//  ClusterSearchCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

protocol ClusterSearchNavigator {
    func lunchClusterDetail(cluster: ClusterDetail) -> Observable<Void>
}
