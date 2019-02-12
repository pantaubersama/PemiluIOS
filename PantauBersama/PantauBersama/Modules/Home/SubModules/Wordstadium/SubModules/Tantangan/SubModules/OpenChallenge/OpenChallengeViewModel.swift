//
//  OpenChallengeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

class OpenChallengeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let refreshI: AnyObserver<Void>
        let kajianI: AnyObserver<Bool>
        let pernyataanI: AnyObserver<Bool>
        let dateTimeI: AnyObserver<Bool>
        let saldoI: AnyObserver<Bool>
        let kajianButtonI: AnyObserver<Void>
        let hintKajianI: AnyObserver<Void>
    }
    
    struct Output {
        let itemsO: Driver<[SectionOfTantanganData]>
        let meO: Driver<User>
        let kajianSelected: Driver<BidangKajianResult>
        let hintKajianO: Driver<Void>
    }
    
    private let backS = PublishSubject<Void>()
    private let refreshS = PublishSubject<Void>()
    private let kajianS = PublishSubject<Bool>()
    private let pernyataanS = PublishSubject<Bool>()
    private let dateTimeS = PublishSubject<Bool>()
    private let saldoS = PublishSubject<Bool>()
    private let kajianButtonS = PublishSubject<Void>()
    private let hintKajianS = PublishSubject<Void>()
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private var navigator: OpenChallengeNavigator
    
    init(navigator: OpenChallengeNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      kajianI: kajianS.asObserver(),
                      pernyataanI: pernyataanS.asObserver(),
                      dateTimeI: dateTimeS.asObserver(),
                      saldoI: saldoS.asObserver(),
                      kajianButtonI: kajianButtonS.asObserver(),
                      hintKajianI: hintKajianS.asObserver())
        
        
        let item = Observable.combineLatest(kajianS, pernyataanS, dateTimeS, saldoS)
            .flatMapLatest { (valueKajian, valuePernyataan, valueData, valueSaldo) -> Observable<[SectionOfTantanganData]> in
                return Observable.just([
                    SectionOfTantanganData(items: [TantanganData.bidangKajian], isHide: valueKajian, isActive: valueKajian),
                    SectionOfTantanganData(items: [TantanganData.pernyataan], isHide: valuePernyataan, isActive: valuePernyataan),
                    SectionOfTantanganData(items: [TantanganData.dateTime], isHide: valueData, isActive: valueData),
                    SectionOfTantanganData(items: [TantanganData.saldoTime], isHide: valueSaldo, isActive: valueSaldo),
                    ])
        }
        
        let items = item
            .map { (a) -> [SectionOfTantanganData] in
                return a.filter({ $0.isHide == false })
            }
            .asDriverOnErrorJustComplete()
        
        let me = refreshS
            .flatMapLatest { [unowned self] (_) -> Observable<User> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.me,
                                   c: BaseResponse<UserResponse>.self)
                    .map({ $0.data.user })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                    .catchErrorJustComplete()
            }
        
        let kajian = kajianButtonS
            .flatMapLatest({ navigator.launchBidangKajian() })
            .asDriverOnErrorJustComplete()
        
        let hintKajian = hintKajianS
            .flatMapLatest({ navigator.launchHint(type: .kajian )})
            .asDriverOnErrorJustComplete()
        
        output = Output(itemsO: items,
                        meO: me.asDriverOnErrorJustComplete(),
                        kajianSelected: kajian,
                        hintKajianO: hintKajian)
    }
    
}
