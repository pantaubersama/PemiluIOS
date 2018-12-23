//
//  BannerInfoAskCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class BannerInfoAskCell: UITableViewCell, IReusableCell {

    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func bind(viewModel: AskViewModel) {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.mapToVoid()
            .bind(to: viewModel.input.infoTrigger)
            .disposed(by: disposeBag)
    }
    
}
