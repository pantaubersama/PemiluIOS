//
//  AskNavigator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

protocol QuestionNavigator {
    func launchCreateAsk() -> Observable<Void>
    func shareQuestion(question: String) -> Observable<Void>
}
