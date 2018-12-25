//
//  AskViewCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Common

class AskViewCell: UITableViewCell, IReusableCell  {

    private(set) var disposeBag = DisposeBag()
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    // TODO: change to Ask model
    var ask: Any! {
        didSet {
            // TODO: view configuration
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func bind(viewModel: AskViewModel) {
        moreButton.rx.tap
            .map({ self.ask })
            .bind(to: viewModel.input.moreTrigger)
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .map({ self.ask })
            .bind(to: viewModel.input.shareTrigger)
            .disposed(by: disposeBag)
        
    }
}
