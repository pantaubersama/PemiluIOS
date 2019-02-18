//
//  PersonalNavigator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol PersonalNavigator {
    func launchChallenge(wordstadium: Wordstadium) -> Observable<Void>
}
