//
//  WordstadiumListViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class WordstadiumListViewModel: ViewModelType {
    var input: Input!
    var output: Output!
    
    struct Input {
        let backTriggger: AnyObserver<Void>
        let refreshTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let items: Driver<[SectionWordstadium]>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }
    
    private var navigator: WordstadiumListNavigator
    private let backSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: WordstadiumListNavigator, progress: ProgressType, liniType: LiniType) {
        self.navigator = navigator
        self.navigator.finish = backSubject
        
        input = Input(backTriggger: backSubject.asObserver(),
                      refreshTrigger: refreshSubject.asObserver())
        
        
        let showItems = refreshSubject.startWith(())
            .flatMapLatest({ [weak self] (_) -> Observable<[SectionWordstadium]> in
                guard let `self` = self else { return Observable<[SectionWordstadium]>.just([]) }
                return self.getChallenge(progress: progress, type: liniType)
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(items: showItems,
                        isLoading: activityIndicator.asDriver(),
                        error: errorTracker.asDriver())
    }
    
    func getChallenge(progress: ProgressType, type: LiniType) -> Observable<[SectionWordstadium]>{
        return NetworkService.instance
            .requestObject(WordstadiumAPI.getChallenges(progress: progress, type: type),
                           c: BaseResponse<GetChallengeResponse>.self)
            .map{( self.transformToSection(challenge: $0.data.challenges, progress: progress, type: type) )}
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
    }
    
    func transformToSection(challenge: [Challenge],progress: ProgressType, type: LiniType) -> [SectionWordstadium] {
        var item:[Challenge] = []
        var itemLive:[Challenge] = []
        var title: String = ""
        var description: String = ""
        
        switch progress {
        case .liveNow:
            itemLive = challenge
            if type == .public {
                title = "Live Now"
                description = "Ini daftar debat yang sedang berlangsung. Yuk, pantau bersama!"
            } else {
                title = "Challenge in Progress"
                description = "Daftar tantangan yang perlu respon dan perlu konfirmasi ditampilkan semua disini. Jangan sampai terlewatkan, yaa."
            }
        case .comingSoon:
            item = challenge
            if type == .public {
                title = "Debat: Coming Soon"
            } else {
                title = "My Debat: Coming Soon"
            }
            description = "Jangan lewatkan daftar debat yang akan segera berlangsung. Catat jadwalnya, yaa."
        case .done:
            item = challenge
            if type == .public {
                title = "Debat: Done"
            } else {
                title = "My Debat: Done"
            }
            description = "Berikan komentar dan appresiasi pada debat-debat yang sudah selesai. Daftarnya ada di /Users/rahardyan/Documents/Rahardyan Bisma Setya Putra/pantau-bersama-ios/PantauBersama/PantauBersama/Library/CustomView/FooterProfileViewbawah ini:"
        case .challenge:
            item = challenge
            if type == .public {
                title = "Challenge"
                description = "Daftar Open Challenge yang bisa diikuti. Pilih debat mana yang kamu ingin ambil tantangannya. Be truthful and gentle!"
            } else {
                title = "My Challenge"
                description = "Daftar tantangan yang perlu respon dan perlu konfirmasi ditampilkan semua disini. Jangan sampai terlewatkan, yaa."
            }
        }
        
        return [SectionWordstadium(title: title, descriptiom: description,type: type, itemType: progress, items: item, itemsLive: itemLive )]
    }
}
