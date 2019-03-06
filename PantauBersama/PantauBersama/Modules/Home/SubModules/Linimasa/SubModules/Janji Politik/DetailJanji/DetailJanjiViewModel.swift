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

enum DetailJanpolResult {
    case cancel
    case result(String)
}

class DetailJanjiViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let moreTrigger: AnyObserver<Void>
        let moreMenuTrigger: AnyObserver<JanjiType>
        let shareTrigger: AnyObserver<Void>
        let closeTrigger: AnyObserver<Void>
        let deleteTrigger: AnyObserver<String>
        let profileTrigger: AnyObserver<UITapGestureRecognizer>
        let clusterTrigger: AnyObserver<UITapGestureRecognizer>
        let refreshTrigger: AnyObserver<String>
    }
    
    struct Output {
        let shareSelected: Driver<Void>
        let moreSelected: Driver<JanjiPolitik>
        let moreMenuSelected: Driver<String>
        let detailJanji: Driver<JanjiPolitik>
        let closeSelected: Driver<DetailJanpolResult>
        let profileSelected: Driver<Void>
        let clusterSelected: Driver<Void>
    }
    
    private let moreSubject = PublishSubject<Void>()
    private let moreMenuSubject = PublishSubject<JanjiType>()
    private let shareSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    private let deleteSubject = PublishSubject<String>()
    private let profileSubject = PublishSubject<UITapGestureRecognizer>()
    private let clusterSubject = PublishSubject<UITapGestureRecognizer>()
    private let refreshSubject = PublishSubject<String>()
    
    private let navigator: DetailJanjiNavigator
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    let headerViewModel = BannerHeaderViewModel()
    
    init(navigator: DetailJanjiNavigator, data: String) {
        self.navigator = navigator
        
        input = Input(
            moreTrigger: moreSubject.asObserver(),
            moreMenuTrigger: moreMenuSubject.asObserver(),
            shareTrigger: shareSubject.asObserver(),
            closeTrigger: closeSubject.asObserver(),
            deleteTrigger: deleteSubject.asObserver(),
            profileTrigger: profileSubject.asObserver(),
            clusterTrigger: clusterSubject.asObserver(),
            refreshTrigger: refreshSubject.asObserver())
        
        let detail = refreshSubject.startWith("")
            .flatMapLatest { (_) -> Observable<JanjiPolitik> in
                return NetworkService.instance
                    .requestObject(LinimasaAPI.getDetailJanpol(id: data),
                                   c: BaseResponse<CreateJanjiPolitikResponse>.self)
                    .map({ $0.data.janjiPolitik })
                    .do(onSuccess: { (response) in
                        print("Response: \(response)")
                    }, onError: { (e) in
                        print(e.localizedDescription)
                    })
                    .asObservable()
                    .catchErrorJustComplete()
        }
        
        let moreSelected = moreSubject
            .withLatestFrom(detail)
            .asDriverOnErrorJustComplete()
        
        let shareJanji = shareSubject
            .withLatestFrom(detail)
            .flatMapLatest({ (data) -> Observable<Void> in
                return navigator.shareJanji(data: data)
            })
            .asDriver(onErrorJustReturn: ())
        
        let moreMenuSelected = moreMenuSubject
            .flatMapLatest { (type) -> Observable<String> in
                switch type {
                case .bagikan:
                    return detail.flatMapLatest({ (data) -> Observable<String> in
                        return navigator.shareJanji(data: data)
                            .map({ (_) -> String in
                                return ""
                            })
                    })
                    
                case .salin:
                    return detail.flatMapLatest({ (data) -> Observable<String> in
                        let urlSalin = "\(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/janjipolitik/\(data.id)"
                        urlSalin.copyToClipboard()
                        return Observable.just("Tautan telah tersalin")
                    })
                case .hapus(let id):
                    return self.delete(id: id)
                        .do(onNext: { (response) in
                            print("delete response: \(response)")
                            self.deleteSubject.onNext(id)
                        })
                        .map({ (_) -> String in
                            return ""
                        })
                default:
                    return Observable.empty()
                }
            }
            .asDriverOnErrorJustComplete()
        
        let backSelected = closeSubject.map({ DetailJanpolResult.cancel })
        let deleteSelected = deleteSubject
            .map{ (result) in DetailJanpolResult.result(result) }
        
        let closeSelected = Observable.merge(backSelected, deleteSelected)
            .take(1)
            .asDriverOnErrorJustComplete()
        
        
        let profile = profileSubject
            .withLatestFrom(detail)
            .flatMapLatest { (janji) -> Observable<Void> in
                if let myId = AppState.local()?.user.id {
                    if myId == janji.creator.id {
                        return navigator.launchProfileUser(isMyAccount: true, userId: nil)
                    } else {
                        return navigator.launchProfileUser(isMyAccount: false, userId: janji.creator.id)
                    }
                }
                return Observable.empty()
            }
            .asDriverOnErrorJustComplete()
        
        let cluster = clusterSubject
            .withLatestFrom(detail)
            .flatMapLatest { (janpol) -> Observable<Void> in
                if let cluster = janpol.creator.cluster {
                    return navigator.launchClusterDetail(cluster: cluster)
                }
                return Observable.empty()
            }
            .asDriverOnErrorJustComplete()
            
        
        output = Output(
            shareSelected: shareJanji,
            moreSelected: moreSelected,
            moreMenuSelected: moreMenuSelected,
            detailJanji: detail.asDriverOnErrorJustComplete(),
            closeSelected: closeSelected,
            profileSelected: profile,
            clusterSelected: cluster)
        
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
