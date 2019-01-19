//
//  File.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

protocol QuizNavigator {
    // TODO: replace Any with Quiz model
    func openQuiz(quiz: QuizModel) -> Observable<Void>
    func shareQuiz(quiz: QuizModel) -> Observable<Void>
    func shareTrend(trend: Any) -> Observable<Void>
}
