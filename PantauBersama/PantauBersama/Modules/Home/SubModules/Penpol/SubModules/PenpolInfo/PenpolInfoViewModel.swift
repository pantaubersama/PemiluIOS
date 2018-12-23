//
//  PenpolInfoViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

enum PenpolInfoType {
    case Ask
    case Quiz
}

class PenpolInfoViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        let finishTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let finish: Driver<Void>
        let quizInfoCell: Driver<[ICellConfigurator]>
    }
    
    private let finishSubject = PublishSubject<Void>()
    init(infoType: PenpolInfoType) {
        input = Input(finishTrigger: finishSubject.asObserver())
        
        let quizInfoCells = [PenpolInfoViewCellConfigurator(item: PenpolInfoCell.Input(viewModel: PenpolInfoCellViewModel(), infoType: infoType))]
        let quizCellDriver: Driver<[ICellConfigurator]> = Observable.just(quizInfoCells).asDriverOnErrorJustComplete()
        
        let finish = finishSubject.asDriverOnErrorJustComplete()
        output = Output(finish: finish,
                        quizInfoCell: quizCellDriver)
    }
}
