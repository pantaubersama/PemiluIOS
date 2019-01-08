//
//  IClusterSearchDelegate.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Networking
import RxSwift

protocol IClusterSearchDelegate {
    func didSelectCluster(item: ClusterDetail, index: IndexPath) -> Observable<Void>
}
