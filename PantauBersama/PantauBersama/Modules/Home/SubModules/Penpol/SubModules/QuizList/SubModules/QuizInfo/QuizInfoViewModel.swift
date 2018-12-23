//
//  QuizInfoViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class QuizInfoViewModel: ViewModelType {
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
    init() {
        input = Input(finishTrigger: finishSubject.asObserver())
        
        let quizInfoCells = [QuizInfoViewCellConfigurator(item: QuizInfoCell.Input(viewModel: QuizInfoCellViewModel()))]
        let quizCellDriver: Driver<[ICellConfigurator]> = Observable.just(quizInfoCells).asDriverOnErrorJustComplete()
        
        let finish = finishSubject.asDriverOnErrorJustComplete()
        output = Output(finish: finish,
                        quizInfoCell: quizCellDriver)
    }
}
