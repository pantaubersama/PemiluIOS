//
//  SaldoTimeCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Common

enum SaldoTime {
    case halfHour
    case oneHour
    case oneHalfHour
    case twoHour
    case twoHalfHour
    case threeHour
    
    var title: String? {
        switch self {
        case .halfHour:
            return "30"
        case .oneHour:
            return "60"
        case .oneHalfHour:
            return "90"
        case .twoHour:
            return "120"
        case .twoHalfHour:
            return "150"
        case .threeHour:
            return "180"
        }
    }
    
    func index(title: String?) -> Int {
        guard let title = title else { return 6 }
        switch title {
        case "30":
            return 0
        case "60":
            return 1
        case "90":
            return 2
        case "120":
            return 3
        case "150":
            return 4
        case "180":
            return 5
        default:
            return 6
        }
    }
    
}


class SaldoTimeCell: UITableViewCell {
    
    private var disposeBag: DisposeBag!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var tvSaldo: UITextField!
    @IBOutlet weak var btnHint: UIButton!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension SaldoTimeCell: IReusableCell {
    
    struct Input {
        let viewModel: OpenChallengeViewModel
        let status: Bool
        let saldo: String?
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        let pickerView = UIPickerView()
        
        status.image = item.status ? #imageLiteral(resourceName: "checkDone") : #imageLiteral(resourceName: "checkUnactive")
        
        if item.saldo == nil {
            tvSaldo.text = "Pilih saldo waktu"
        } else {
            tvSaldo.text = item.saldo
        }
        
        let data = [
            SaldoTime.halfHour,
            SaldoTime.oneHour,
            SaldoTime.oneHalfHour,
            SaldoTime.twoHour,
            SaldoTime.twoHalfHour,
            SaldoTime.threeHour
        ]
        
        Observable.just(data)
            .bind(to: pickerView.rx.itemTitles) { (row, element) in
                return element.title
            }
            .disposed(by: bag)
        
        pickerView.rx.modelSelected(SaldoTime.self)
            .flatMapLatest({ $0.first.map({ Observable.just($0)}) ?? Observable.empty() })
            .map({ $0.title ?? "" })
            .asDriverOnErrorJustComplete()
            .drive(tvSaldo.rx.text)
            .disposed(by: bag)
        
        tvSaldo.rx.controlEvent(UIControl.Event.editingDidEnd)
            .map({ self.tvSaldo.text ?? ""})
            .bind(to: item.viewModel.input.saldoTimeI)
            .disposed(by: bag)
        
        tvSaldo.inputView = pickerView
        
        btnHint.rx.tap
            .bind(to: item.viewModel.input.hintSaldoI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
}
