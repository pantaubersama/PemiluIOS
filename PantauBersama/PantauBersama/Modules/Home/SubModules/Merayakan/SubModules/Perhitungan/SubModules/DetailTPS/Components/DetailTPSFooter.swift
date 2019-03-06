//
//  DetailTPSFooter.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 28/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class DetailTPSFooter: UITableViewCell, IReusableCell {
    @IBOutlet weak var btnUpload: Button!
    
    private var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
    struct Input {
        let viewModel: DetailTPSViewModel
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()

        btnUpload.rx.tap
            .bind(to: item.viewModel.input.c1UploadI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
}
