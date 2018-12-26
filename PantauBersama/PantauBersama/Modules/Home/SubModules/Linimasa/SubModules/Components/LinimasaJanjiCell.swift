//
//  LinimasaJanjiCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class LinimasaJanjiCell: UITableViewCell, IReusableCell {
    
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    var janji: Any! {
        didSet {
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func bind(viewModel: JanjiPolitikViewModel) {
        shareBtn.rx.tap
            .map({ self.janji })
            .bind(to: viewModel.input.shareJanji)
            .disposed(by: disposeBag)
        
        moreBtn.rx.tap
            .map({ self.janji })
            .bind(to: viewModel.input.moreTrigger)
            .disposed(by: disposeBag)
    }
}
