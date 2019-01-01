//
//  LinimasaCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

typealias LinimasaCellConfigured = CellConfigurator<LinimasaCell, LinimasaCell.Input>

class LinimasaCell: UITableViewCell  {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: Label!
    @IBOutlet weak var content: Label!
    @IBOutlet weak var titleTeam: Label!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var more: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
}

extension LinimasaCell: IReusableCell {
    
    struct Input {
        let viewModel: PilpresViewModel
        let feeds: Feeds
    }
    
    func configureCell(item: Input) {
        let feeds = item.feeds
        let bag = DisposeBag()
        
        configure(data: feeds)
        
        more.rx.tap
            .map({ feeds })
            .bind(to: item.viewModel.input.moreTrigger)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
    func configure(data: Feeds) {
        
        name.text = data.account.name
        content.text = data.source.text
        titleTeam.text = data.team.title
        
        avatar.af_setImage(withURL: URL(string: data.account.profileImageUrl)!)
        thumbnail.af_setImage(withURL: URL(string: data.team.avatar)!)

    }
    
}
