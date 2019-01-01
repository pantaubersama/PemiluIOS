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
import Networking

typealias LinimasaJanjiCellConfigured = CellConfigurator<LinimasaJanjiCell, LinimasaJanjiCell.Input>

class LinimasaJanjiCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullname: Label!
    @IBOutlet weak var dateCreate: Label!
    @IBOutlet weak var title: Label!
    @IBOutlet weak var content: Label!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    

}

extension LinimasaJanjiCell: IReusableCell {
    
    struct Input {
        let viewModel: JanjiPolitikViewModel
        let janpol: JanjiPolitik
    }
    
    func configureCell(item: Input) {
        let janpol = item.janpol
        let bag = DisposeBag()
        
        configure(data: janpol)
        
        shareBtn.rx.tap
            .map({ janpol })
            .bind(to: item.viewModel.input.shareJanji)
            .disposed(by: disposeBag)
        
        moreBtn.rx.tap
            .map({ janpol })
            .bind(to: item.viewModel.input.moreTrigger)
            .disposed(by: disposeBag)
        
        disposeBag = bag
    }
    
    func configure(data: JanjiPolitik) {
        
        fullname.text = data.user.firstName + " " + data.user.lastName 
        dateCreate.text = data.createdAt
        title.text = data.title
        content.text = data.body

        avatar.af_setImage(withURL: URL(string: data.image.large?.url ?? "")!)
        
    }
    
}
