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

class WordstadiumListViewModel: ViewModelType {
    var input: Input!
    var output: Output!
    
    struct Input {
        let backTriggger: AnyObserver<Void>
        let refreshTrigger: AnyObserver<String>
    }
    
    struct Output {
        let items: Driver<[SectionWordstadium]>
    }
    
    private var navigator: WordstadiumListNavigator
    private let backSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<String>()
    
    init(navigator: WordstadiumListNavigator,wordstadium: SectionWordstadium) {
        self.navigator = navigator
        self.navigator.finish = backSubject
        
        input = Input(backTriggger: backSubject.asObserver(),
                      refreshTrigger: refreshSubject.asObserver())
        
        let showItems = refreshSubject.startWith("")
            .flatMapLatest({ _ in self.generateListWordstadium(type: wordstadium.itemType) })
            .asDriverOnErrorJustComplete()
        
        output = Output(items: showItems)
    }
    
    
    private func generateListWordstadium(type: ItemType) ->  Observable<[SectionWordstadium]> {
        var items : [SectionWordstadium] = []
        let wordstadium = SectionWordstadium(title: "MY WORDSTADIUM",
                                       descriptiom: "Daftar tantangan dan debat yang akan atau sudah kamu ikuti ditampilkan semua di sini.",
                                       itemType: type,
                                       items: [Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challengeOpen),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challengeDirect),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challengeDenied),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challengeExpired),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge)],
                                       itemsLive: [])
    
        items.append(wordstadium)
        return Observable.just(items)
    }
}
