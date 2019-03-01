//
//  NotificationViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Networking

public enum NotifMenu {
    case all
    case event
}

final class NotificationViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let refreshI: AnyObserver<NotifMenu>
        let itemSelected: AnyObserver<NotificationRecord>
        let changeNotifMenuI: AnyObserver<NotifMenu>
    }
    
    struct Output {
        let backO: Driver<Void>
        let itemSelectedO: Driver<Void>
        let items: Driver<[ICellConfigurator]>
    }
    
    let navigator: NotificationNavigator
    private let disposeBag = DisposeBag()
    
    private let backS = PublishSubject<Void>()
    private let refreshS = PublishSubject<NotifMenu>()
    private let itemSelectedS = PublishSubject<NotificationRecord>()
    private let changeNotifMenuS = PublishSubject<NotifMenu>()
    let errorTrackker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: NotificationNavigator) {
        self.navigator = navigator
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      itemSelected: itemSelectedS.asObserver(),
                      changeNotifMenuI: changeNotifMenuS.asObserver())
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let items = refreshS.startWith(.all)
            .flatMapLatest { [unowned self] (menuType) -> Observable<[NotificationRecord]> in
                return NetworkService
                    .instance
                    .requestObject(NotificationAPI.recordNotification,
                                   c: BaseResponse<RecordNotificationResponse>.self)
                    .map({ (response) -> [NotificationRecord] in
                        switch menuType {
                        case .all:
                            return response.data.notifications
                        case .event:
                            return response.data.notifications.filter({ $0.data.payload != nil && $0.data.payload?.notifType == "broadcasts" })
                        }
                    })
                    .do(onSuccess: { (response) in
                        print(response)
                    }, onError: { (error) in
                        print(error.localizedDescription)
                    })
                    .trackError(self.errorTrackker)
                    .trackActivity(self.activityIndicator)
        }
        
        let itemSelected = itemSelectedS
            .flatMapLatest({ [unowned self](notif) -> Observable<Void> in
                guard let notifTypeString = notif.data.payload?.notifType else { return Observable.never() }
                guard let notifType = NotifType(rawValue: notifTypeString) else { return Observable.never() }
                
                switch notifType {
                case .question:
                    guard let question = notif.data.payload?.question else { return Observable.never() }
                    return self.navigator.openQuestion(questionId: question.id)
                case .badge:
                    guard let badge = notif.data.payload?.badge else { return Observable.never() }
                    return self.navigator.openShareBadge(badge: badge.badge)
                case .quiz:
                    return self.navigator.openQuizPage()
                default:
                    return Observable.never()
                }
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let itemCell = items
            .map { (list) -> [ICellConfigurator] in
                return list.map({ (notif) -> ICellConfigurator in
                    return InfoNotifiCellConfigured(item: InfoNotifCell.Input(notif: notif))
                })
        }
        
        changeNotifMenuS
            .bind(to: refreshS)
            .disposed(by: disposeBag)
        
        output = Output(backO: back,
                        itemSelectedO: itemSelected,
                        items: itemCell.asDriver(onErrorJustReturn: []))
    }
}
