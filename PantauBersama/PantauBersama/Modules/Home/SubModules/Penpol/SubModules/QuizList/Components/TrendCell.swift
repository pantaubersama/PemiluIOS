//
//  TrendCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class TrendCell: UITableViewCell, IReusableCell {
    @IBOutlet weak var ivPaslon: UIImageView!
    @IBOutlet weak var lbTotal: Label!
    @IBOutlet weak var lbKecenderungan: Label!
    @IBOutlet weak var btnShare: UIButton!
    
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    // TODO: change to Quiz model
    var trend: Any! {
        didSet {
            // TODO: view configuration
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func bind(viewModel: QuizViewModel) {
        
        btnShare.rx.tap
            .map({ self.trend })
            .bind(to: viewModel.input.shareTrigger)
            .disposed(by: disposeBag)
        
    }
}
