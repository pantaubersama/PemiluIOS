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

protocol JanjiPolitikNavigator {
    func shareJanji(data: Any) -> Observable<Void>
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<Void>
}
