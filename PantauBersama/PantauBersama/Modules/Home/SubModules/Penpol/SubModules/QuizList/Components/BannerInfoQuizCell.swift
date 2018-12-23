//
//  BannerInfoQuizCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class BannerInfoQuizCell: UITableViewCell, IReusableCell {
    @IBOutlet weak var ivInfo: UIImageView!
    @IBOutlet weak var lbReadMore: Label!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func bind(viewModel: QuizViewModel) {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.mapToVoid()
            .bind(to: viewModel.input.infoTrigger)
            .disposed(by: disposeBag)
    }
}
