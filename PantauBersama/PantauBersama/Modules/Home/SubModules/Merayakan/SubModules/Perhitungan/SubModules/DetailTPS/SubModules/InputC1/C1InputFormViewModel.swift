//
//  InputC1ViewModel.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class C1InputFormViewModel: ViewModelType {
    
    struct Input {
        let backI: AnyObserver<Void>
        let simpanI: AnyObserver<Void>
        
        let A3LakiI: AnyObserver<String>
        let A3PerempuanI: AnyObserver<String>
        let A4LakiI: AnyObserver<String>
        let A4PerempuanI: AnyObserver<String>
        let ADPKLakiI: AnyObserver<String>
        let ADPKPerempuanI: AnyObserver<String>
        
        let C7DPTLakiI: AnyObserver<String>
        let C7DPTPerempuanI: AnyObserver<String>
        let C7DPTBLakiI: AnyObserver<String>
        let C7DPTBPerempuanI: AnyObserver<String>
        let C7DPKLakiI: AnyObserver<String>
        let C7DPKPerempuanI: AnyObserver<String>
        
        let disTerdaftarLakiI: AnyObserver<String>
        let disTerdaftarPerempuanI: AnyObserver<String>
        let disPilihLakiI: AnyObserver<String>
        let disPilihPerempuanI: AnyObserver<String>
        
        let suratDikembalikanI: AnyObserver<String>
        let suratTidakDigunakanI: AnyObserver<String>
        let suratDigunakanI: AnyObserver<String>
    }
    
    struct Output {
        let backO: Driver<Void>
        let simpanO: Driver<Void>
        
        let A3TotalO: Driver<String>
        let A4TotalO: Driver<String>
        let ADPKTotalO: Driver<String>
        let TotaLakiA3O: Driver<String>
        let TotalPerempuanA3O: Driver<String>
        let TotalAllA3O: Driver<String>
        
        let C7DPTTotalO: Driver<String>
        let C7DPTBTotalO: Driver<String>
        let C7DPKTotalO: Driver<String>
        let TotalLakiC7O: Driver<String>
        let TotalPerempuanC7O: Driver<String>
        let TotalAllC7O: Driver<String>
        
        let disTerdaftarTotalO: Driver<String>
        let disPilihTotalO: Driver<String>
        
        let suratDiterimaO: Driver<String>
    }
    
    
    var input: Input
    var output: Output
    
    private let navigator: C1InputFormNavigator
    private let backS = PublishSubject<Void>()
    private let simpanS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    
    private let A3LakiS = PublishSubject<String>()
    private let A3PerempuanS = PublishSubject<String>()
    private let A4LakiS = PublishSubject<String>()
    private let A4PerempuanS = PublishSubject<String>()
    private let ADPKLakiS = PublishSubject<String>()
    private let ADPKPerempuanS = PublishSubject<String>()
    
    private let C7DPTLakiS = PublishSubject<String>()
    private let C7DPTPerempuanS = PublishSubject<String>()
    private let C7DPTBLakiS = PublishSubject<String>()
    private let C7DPTBPerempuanS = PublishSubject<String>()
    private let C7DPKLakiS = PublishSubject<String>()
    private let C7DPKPerempuanS = PublishSubject<String>()

    
    private let disTerdaftarLakiS = PublishSubject<String>()
    private let disTerdaftarPerempuanS = PublishSubject<String>()
    private let disPilihLakiS = PublishSubject<String>()
    private let disPilihPerempuanS = PublishSubject<String>()
    
    private let suratDikembalikanS = PublishSubject<String>()
    private let suratTidakDigunakanS = PublishSubject<String>()
    private let suratDigunakanS = PublishSubject<String>()
    
    init(navigator: C1InputFormNavigator) {
        self.navigator = navigator
        
        input = Input(backI: backS.asObserver(),
                      simpanI: simpanS.asObserver(),
                      A3LakiI: A3LakiS.asObserver(),
                      A3PerempuanI: A3PerempuanS.asObserver(),
                      A4LakiI: A4LakiS.asObserver(),
                      A4PerempuanI: A4PerempuanS.asObserver(),
                      ADPKLakiI: ADPKLakiS.asObserver(),
                      ADPKPerempuanI: ADPKPerempuanS.asObserver(),
                      C7DPTLakiI: C7DPTLakiS.asObserver(),
                      C7DPTPerempuanI: C7DPTPerempuanS.asObserver(),
                      C7DPTBLakiI: C7DPTBLakiS.asObserver(),
                      C7DPTBPerempuanI: C7DPTBPerempuanS.asObserver(),
                      C7DPKLakiI: C7DPKLakiS.asObserver(),
                      C7DPKPerempuanI: C7DPKPerempuanS.asObserver(),
                      disTerdaftarLakiI: disTerdaftarLakiS.asObserver(),
                      disTerdaftarPerempuanI: disTerdaftarPerempuanS.asObserver(),
                      disPilihLakiI: disPilihLakiS.asObserver(),
                      disPilihPerempuanI: disPilihPerempuanS.asObserver(),
                      suratDikembalikanI: suratDikembalikanS.asObserver(),
                      suratTidakDigunakanI: suratTidakDigunakanS.asObserver(),
                      suratDigunakanI: suratDigunakanS.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let a3Total = Observable.combineLatest(A3LakiS, A3PerempuanS)
            .map { (laki, perempuan) -> String in
                let total = (Int(laki) ?? 0) + (Int(perempuan) ?? 0)
                return "\(total)"
            }
            .startWith("0")
            .asDriver(onErrorJustReturn: "0")
        let a4Total = Observable.combineLatest(A4LakiS, A4PerempuanS)
            .map { (laki, perempuan) -> String in
                let total = (Int(laki) ?? 0) + (Int(perempuan) ?? 0)
                return "\(total)"
            }
            .startWith("0")
            .asDriver(onErrorJustReturn: "0")
        let aDPKTotal = Observable.combineLatest(ADPKLakiS, ADPKPerempuanS)
            .map { (laki, perempuan) -> String in
                let total = (Int(laki) ?? 0) + (Int(perempuan) ?? 0)
                return "\(total)"
            }
            .startWith("0")
            .asDriver(onErrorJustReturn: "0")
        let totaLakiA3 = Observable.combineLatest(A3LakiS, A4LakiS, ADPKLakiS)
            .map { (a3, a4, adpk) -> String in
                let total = (Int(a3) ?? 0) + (Int(a3) ?? 0) + (Int(adpk) ?? 0)
                return "\(total)"
            }
            .startWith("0")
        let totaPerempuanA3 = Observable.combineLatest(A3PerempuanS, A4PerempuanS, ADPKPerempuanS)
            .map { (a3, a4, adpk) -> String in
                let total = (Int(a3) ?? 0) + (Int(a3) ?? 0) + (Int(adpk) ?? 0)
                return "\(total)"
            }
            .startWith("0")
        let totalAllA3 = Observable.combineLatest(totaLakiA3, totaPerempuanA3)
            .map { (laki, perempuan) -> String in
                let total = (Int(laki) ?? 0) + (Int(perempuan) ?? 0)
                return "\(total)"
            }
            .startWith("0")
            .asDriver(onErrorJustReturn: "0")
        
        
        let C7DPTTotal = Observable.combineLatest(C7DPTLakiS, C7DPTPerempuanS)
            .map { (laki, perempuan) -> String in
                let total = (Int(laki) ?? 0) + (Int(perempuan) ?? 0)
                return "\(total)"
            }
            .startWith("0")
            .asDriver(onErrorJustReturn: "0")
        let C7DPTBTotal = Observable.combineLatest(C7DPTBLakiS, C7DPTBPerempuanS)
            .map { (laki, perempuan) -> String in
                let total = (Int(laki) ?? 0) + (Int(perempuan) ?? 0)
                return "\(total)"
            }
            .startWith("0")
            .asDriver(onErrorJustReturn: "0")
        let C7DPKTotal = Observable.combineLatest(C7DPKLakiS, C7DPKPerempuanS)
            .map { (laki, perempuan) -> String in
                let total = (Int(laki) ?? 0) + (Int(perempuan) ?? 0)
                return "\(total)"
            }
            .startWith("0")
            .asDriver(onErrorJustReturn: "0")
        let TotalLakiC7 = Observable.combineLatest(C7DPTLakiS, C7DPTBLakiS, C7DPKLakiS)
            .map { (a3, a4, adpk) -> String in
                let total = (Int(a3) ?? 0) + (Int(a3) ?? 0) + (Int(adpk) ?? 0)
                return "\(total)"
            }
            .startWith("0")
        let TotalPerempuanC7 = Observable.combineLatest(C7DPTPerempuanS, C7DPTBPerempuanS, C7DPKPerempuanS)
            .map { (a3, a4, adpk) -> String in
                let total = (Int(a3) ?? 0) + (Int(a3) ?? 0) + (Int(adpk) ?? 0)
                return "\(total)"
            }
            .startWith("0")
        let TotalAllC7 = Observable.combineLatest(TotalLakiC7, TotalPerempuanC7)
            .map { (laki, perempuan) -> String in
                let total = (Int(laki) ?? 0) + (Int(perempuan) ?? 0)
                return "\(total)"
            }
            .startWith("0")
            .asDriver(onErrorJustReturn: "0")
        
        
        
        
        let disTerdaftarTotal = Observable.combineLatest(disTerdaftarLakiS, disTerdaftarPerempuanS)
            .map { (laki, perempuan) -> String in
                let total = (Int(laki) ?? 0) + (Int(perempuan) ?? 0)
                return "\(total)"
            }
            .startWith("0")
            .asDriver(onErrorJustReturn: "0")
        
        let disPilihTotal = Observable.combineLatest(disPilihLakiS, disPilihPerempuanS)
            .map { (laki, perempuan) -> String in
                let total = (Int(laki) ?? 0) + (Int(perempuan) ?? 0)
                return "\(total)"
            }
            .startWith("0")
            .asDriver(onErrorJustReturn: "0")
        
        
        output = Output(backO: back,
                        simpanO: Driver.empty(),
                        A3TotalO: a3Total,
                        A4TotalO: a4Total,
                        ADPKTotalO: aDPKTotal,
                        TotaLakiA3O: totaLakiA3.asDriver(onErrorJustReturn: "0"),
                        TotalPerempuanA3O: totaPerempuanA3.asDriver(onErrorJustReturn: "0"),
                        TotalAllA3O: totalAllA3,
                        C7DPTTotalO: C7DPTTotal,
                        C7DPTBTotalO: C7DPTBTotal,
                        C7DPKTotalO: C7DPKTotal,
                        TotalLakiC7O: TotalLakiC7.asDriver(onErrorJustReturn: "0"),
                        TotalPerempuanC7O: TotalPerempuanC7.asDriver(onErrorJustReturn: "0"),
                        TotalAllC7O: TotalAllC7,
                        disTerdaftarTotalO: disTerdaftarTotal,
                        disPilihTotalO: disPilihTotal,
                        suratDiterimaO: Driver.just("0"))
    }
}
