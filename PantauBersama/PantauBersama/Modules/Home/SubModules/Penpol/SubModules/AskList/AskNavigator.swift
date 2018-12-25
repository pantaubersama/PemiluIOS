//
//  AskNavigator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

protocol AskNavigator {
    func launchCreateAsk() -> Observable<Void>
    func shareAsk(ask: Any) -> Observable<Void>
}
