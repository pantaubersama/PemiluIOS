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
        let viewTypeTrigger: AnyObserver<DebatViewType>
    }
    
    struct Output {
        let back: Driver<Void>
        let launchDetail: Driver<Void>
        let showComment: Driver<Void>
        let viewType: Driver<DebatViewType>
    }
    
    var input: Input
    var output: Output
    private let navigator: LiveDebatNavigator
    
    private let backS = PublishSubject<Void>()
    private let detailS = PublishSubject<Void>()
    private let commentS = PublishSubject<Void>()
    private let viewTypeS = PublishSubject<DebatViewType>()
    
    init(navigator: LiveDebatNavigator, viewType: DebatViewType) {
        self.navigator = navigator
        
        input = Input(
            backTrigger: backS.asObserver(),
            launchDetailTrigger: detailS.asObserver(),
            showCommentTrigger: commentS.asObserver(),
            viewTypeTrigger: viewTypeS.asObserver()
        )
        
        let back = backS.flatMap({navigator.back()})
            .asDriverOnErrorJustComplete()
        
        let detail = detailS.flatMap({navigator.launchDetail()})
            .asDriverOnErrorJustComplete()
        
        let comment = commentS.flatMap({navigator.showComment()})
            .asDriverOnErrorJustComplete()
        
        let viewType = viewTypeS.startWith(viewType)
            .asDriverOnErrorJustComplete()
        
        output = Output(
            back: back,
            launchDetail: detail,
            showComment: comment,
            viewType: viewType)
    }
}
