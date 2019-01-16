//
//  ReqClusterViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking


enum ResultCategory {
    case cancel
    case done(data: ICategories)
}

enum ResultRequest {
    case cancel
    case create
}

class ReqClusterViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        let backI: AnyObserver<Void>
        let categoriesI: AnyObserver<Void>
        let clusterNameI: AnyObserver<String>
        let clusterDescI: AnyObserver<String>
        let clusterAvatarI: AnyObserver<UIImage?>
        let createI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<ResultRequest>!
        let categoriesO: Driver<ICategories>
        let createO: Driver<Void>
        let enableCreateO: Driver<Bool>
    }
    
    private let navigator: ReqClusterNavigator!
    private let backS = PublishSubject<Void>()
    private let categoriesS = PublishSubject<Void>()
    private let clusterNameS = PublishSubject<String>()
    private let clusterDescS = PublishSubject<String>()
    private let clusterAvatarS = PublishSubject<UIImage?>()
    private let createS = PublishSubject<Void>()
    
    init(navigator: ReqClusterNavigator) {
        self.navigator = navigator
        
        input = Input(
            backI: backS.asObserver(),
            categoriesI: categoriesS.asObserver(),
            clusterNameI: clusterNameS.asObserver(),
            clusterDescI: clusterDescS.asObserver(),
            clusterAvatarI: clusterAvatarS.asObserver(),
            createI: createS.asObserver()
        )
        
        let category = categoriesS
            .flatMapLatest({ navigator.launchKategori() })
            .do(onNext: { (result) in
                switch result {
                case .done(let data):
                    print(data)
                default: break
                }
            })
            .flatMapLatest { (result) -> Observable<ICategories> in
                switch result {
                case .cancel:
                    return Observable.empty()
                case .done(let data):
                    return Observable.just(data)
                }
            }
            .share()
        
        let categoryId = category.map({ $0.id }).share()
        
        let form = Observable.combineLatest(
            clusterAvatarS,
            clusterNameS,
            categoryId,
            clusterDescS
        ).share()
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        let enableCreate = Observable.combineLatest(
            clusterNameS, clusterDescS, categoryId,
            clusterAvatarS
            ).map { (n, d, id, a) -> Bool in
                return n.count > 0 && d.count > 0
                    && id?.count ?? 0 > 0 && a != nil
            }.startWith(false)
            .asDriverOnErrorJustComplete()
        
        let createAction = createS
            .withLatestFrom(form)
            .flatMapLatest { (avatar,name,id,desc) in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI
                        .createCluster(name: name,
                                       id: id ?? "",
                                       desc: desc,
                                       image: avatar),
                                   c: BaseResponse<SingleCluster>.self)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()
        
        
        let dismissSelected = Observable.merge([
                backS.map({ ResultRequest.cancel }),
                createAction.map({ ResultRequest.create })
            ])
        
        output = Output(
            backO: dismissSelected.asDriverOnErrorJustComplete(),
            categoriesO: category.asDriverOnErrorJustComplete(),
            createO: createAction.asDriverOnErrorJustComplete(),
            enableCreateO: enableCreate)
    }
}
