//
//  LiveDebatViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class LiveDebatViewModel: ViewModelType {
    struct Input {
        let backTrigger: AnyObserver<Void>
        let launchDetailTrigger: AnyObserver<Void>
        let showCommentTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let back: Driver<Void>
        let launchDetail: Driver<Void>
        let showComment: Driver<Void>
    }
    
    var input: Input
    var output: Output
    var navigator: LiveDebatNavigator
    
    private let backS = PublishSubject<Void>()
    private let detailS = PublishSubject<Void>()
    private let commentS = PublishSubject<Void>()
    
    init(navigator: LiveDebatNavigator) {
        self.navigator = navigator
        
        input = Input(
            backTrigger: backS.asObserver(),
            launchDetailTrigger: detailS.asObserver(),
            showCommentTrigger: commentS.asObserver()
        )
        
        let back = backS.flatMap({navigator.back()})
            .asDriverOnErrorJustComplete()
        
        let detail = detailS.flatMap({navigator.launchDetail()})
            .asDriverOnErrorJustComplete()
        
        let comment = commentS.flatMap({navigator.showComment()})
            .asDriverOnErrorJustComplete()
        
        output = Output(
            back: back,
            launchDetail: detail,
            showComment: comment)
    }
}
