//
//  ElectionTypeCell.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 28/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class ElectionTypeCell: UITableViewCell, IReusableCell {
    @IBOutlet weak var lblTitle: Label!
    @IBOutlet weak var btnFirstOption: Button!
    @IBOutlet weak var btnSecOption: Button!

    private var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
    struct Input {
        let data: ElectionType
        let viewModel: DetailTPSViewModel
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        lblTitle.text = item.data.title
        btnFirstOption.setImage(item.data.imgFirstOption, for: .normal)
        btnSecOption.setImage(item.data.imgSecOption, for: .normal)
        
        switch item.data.tag {
        case 0:
            btnFirstOption.rx.tap
                .bind(to: item.viewModel.input.detailPresidenI)
                .disposed(by: bag)
            
            btnSecOption.rx.tap
                .bind(to: item.viewModel.input.c1PresidenI)
                .disposed(by: bag)
            
        case 1:
            btnFirstOption.rx.tap
                .bind(to: item.viewModel.input.detailDPRI)
                .disposed(by: bag)
            btnSecOption.rx.tap
                .bind(to: item.viewModel.input.c1DPRI)
                .disposed(by: bag)
            
        case 2:
            btnFirstOption.rx.tap
                .bind(to: item.viewModel.input.detailDPDI)
                .disposed(by: bag)
            
            btnSecOption.rx.tap
                .bind(to: item.viewModel.input.c1DPDI)
                .disposed(by: bag)
            
        case 3:
            btnFirstOption.rx.tap
                .bind(to: item.viewModel.input.detailDPRProvI)
                .disposed(by: bag)
            btnSecOption.rx.tap
                .bind(to: item.viewModel.input.c1DPRDProvI)
                .disposed(by: bag)
            
        case 4:
            btnFirstOption.rx.tap
                .bind(to: item.viewModel.input.detailDPRKotaI)
                .disposed(by: bag)
            btnSecOption.rx.tap
                .bind(to: item.viewModel.input.c1DPRDProvI)
                .disposed(by: bag)
            
        default:
            break
        }
        
        disposeBag = bag
    }
}
