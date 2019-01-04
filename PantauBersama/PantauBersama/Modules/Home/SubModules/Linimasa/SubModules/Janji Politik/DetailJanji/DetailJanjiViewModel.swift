//
//  DetailJanjiViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class DetailJanjiViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let moreTrigger: AnyObserver<Void>
        let moreMenuTrigger: AnyObserver<JanjiType>
        let shareTrigger: AnyObserver<Void>
        let closeTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let shareSelected: Driver<Void>
        let moreSelected: Driver<JanjiPolitik>
        let moreMenuSelected: Driver<Void>
        let detailJanji: Driver<JanjiPolitik>
        let closeSelected: Driver<Void>
    }
    
    private let moreSubject = PublishSubject<Void>()
    private let moreMenuSubject = PublishSubject<JanjiType>()
    private let shareSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    
    private let navigator: DetailJanjiNavigator
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    let headerViewModel = BannerHeaderViewModel()
    
    init(navigator: DetailJanjiNavigator, data: JanjiPolitik) {
        self.navigator = navigator
        
        input = Input(
            moreTrigger: moreSubject.asObserver(),
            moreMenuTrigger: moreMenuSubject.asObserver(),
            shareTrigger: shareSubject.asObserver(),
            closeTrigger: closeSubject.asObserver())
        
        let moreSelected = moreSubject
            .flatMapLatest({ _ in Observable.of(data) })
            .asDriverOnErrorJustComplete()
        
        let shareJanji = shareSubject
            .flatMapLatest({ _ in navigator.shareJanji(data: "Any") })
            .asDriver(onErrorJustReturn: ())
        
        let moreMenuSelected = moreMenuSubject
            .flatMapLatest { (type) -> Observable<Void> in
                switch type {
                case .bagikan:
                    return navigator.shareJanji(data: "as")
                case .salin:
                    return navigator.shareJanji(data: "as")
                case .hapus(let id):
                    return self.delete(id: id)
                        .do(onNext: { (response) in
                            print("delete response: \(response)")
                            navigator.close()
                        }).mapToVoid()
                default:
                    return Observable.empty()
                }
            }
            .asDriverOnErrorJustComplete()
        
        let closeSelected = closeSubject.asDriverOnErrorJustComplete()
        
        output = Output(
            shareSelected: shareJanji,
            moreSelected: moreSelected,
            moreMenuSelected: moreMenuSelected,
            detailJanji: Driver.of(data),
            closeSelected: closeSelected)
        
    }
    
    private func delete(id: String) -> Observable<InfoResponse> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.deleteJanjiPolitiks(id: id),
                c: InfoResponse.self)
            .asObservable()
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .catchErrorJustComplete()
    }
}
