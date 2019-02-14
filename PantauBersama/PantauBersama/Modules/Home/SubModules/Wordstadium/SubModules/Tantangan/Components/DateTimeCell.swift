//
//  DateTimeCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common

class DateTimeCell: UITableViewCell {
    
    
    @IBOutlet weak var lineStatus: UIView!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var btnHint: UIButton!
    @IBOutlet weak var tvJam: UITextField!
    @IBOutlet weak var tvDate: UITextField!
    
    private var dateText: String?
    private var timeText: String?
    
    private var disposeBag: DisposeBag!
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    lazy var timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        return timePicker
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension DateTimeCell: IReusableCell {
    
    struct Input {
        let viewModel: TantanganChallengeViewModel
        let status: Bool
        let date: String?
        let time: String?
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        lineStatus.backgroundColor = item.status ? #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1) : #colorLiteral(red: 0.7960169315, green: 0.7961130738, blue: 0.7959839106, alpha: 1)
        status.image = item.status ? #imageLiteral(resourceName: "checkDone") : #imageLiteral(resourceName: "checkUnactive")
        
        if item.date == nil {
            tvDate.text = "Pilih Tanggal"
        } else {
            tvDate.text = item.date
        }
        
        if item.time == nil {
            tvJam.text = "Pilih Jam"
        } else {
            tvJam.text = item.time
        }
        
        let currentDate = NSDate()
        datePicker.minimumDate = currentDate as Date
        
        datePicker.rx.date
            .skip(1)
            .map { (date) -> String in
                return date.toString()
            }
            .asDriverOnErrorJustComplete()
            .drive(tvDate.rx.text)
            .disposed(by: bag)
        
        tvDate.inputView = datePicker
        
        timePicker.rx.date
            .skip(1)
            .map({ $0.toString(format: "HH:mm")})
            .asDriverOnErrorJustComplete()
            .drive(tvJam.rx.text)
            .disposed(by: bag)
        
        tvJam.inputView = timePicker
        
        tvDate.rx.controlEvent(UIControlEvents.editingDidEnd)
            .map({ self.tvDate.text ?? ""})
            .bind(to: item.viewModel.input.datePickerI)
            .disposed(by: bag)

        tvJam.rx.controlEvent(UIControlEvents.editingDidEnd)
            .map({ self.tvJam.text ?? "" })
            .bind(to: item.viewModel.input.statusTimeI)
            .disposed(by: bag)
        
        btnHint.rx.tap
            .bind(to: item.viewModel.input.hintDateTimeI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
}
