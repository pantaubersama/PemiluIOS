
//
//  BidangKajianCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class BidangKajianCell: UITableViewCell {
    
    @IBOutlet weak var lineStatus: UIView!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var tagKajian: Label!
    @IBOutlet weak var hintKajian: UIButton!
    @IBOutlet weak var btnKajian: UIButton!
    
    var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension BidangKajianCell: IReusableCell {
    
    struct Input {
        let viewModel: OpenChallengeViewModel
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        btnKajian.rx.tap
            .bind(to: item.viewModel.input.kajianButtonI)
            .disposed(by: bag)
        
        hintKajian.rx.tap
            .bind(to: item.viewModel.input.hintKajianI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
}
