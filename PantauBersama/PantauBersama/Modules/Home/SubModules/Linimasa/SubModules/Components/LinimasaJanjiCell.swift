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
import Alamofire

typealias LinimasaJanjiCellConfigured = CellConfigurator<LinimasaJanjiCell, LinimasaJanjiCell.Input>

class LinimasaJanjiCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullname: Label!
    @IBOutlet weak var dateCreate: Label!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: Label!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var clusterName: Label!
    @IBOutlet weak var imagejJanpol: UIImageView!
    @IBOutlet weak var consImageWidth: NSLayoutConstraint!
    
    
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    

}

extension LinimasaJanjiCell: IReusableCell {
    
    struct Input {
        let viewModel: IJanpolListViewModel
        let janpol: JanjiPolitik
    }
    
    func configureCell(item: Input) {
        let janpol = item.janpol
        let bag = DisposeBag()
        
        configure(data: janpol)
        
        shareBtn.rx.tap
            .map({ janpol })
            .bind(to: item.viewModel.input.shareJanjiI)
            .disposed(by: bag)
        
        moreBtn.rx.tap
            .map({ self.tag })
            .bind(to: item.viewModel.input.moreI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
    func configure(data: JanjiPolitik) {
        if data.creator.cluster != nil {
            fullname.text = "\(data.creator.fullName),"
            clusterName.text = data.creator.cluster?.name ?? ""
        } else {
            fullname.text = data.creator.fullName
        }
        dateCreate.text = data.createdAtWord.id
        title.text = data.title
        content.text = data.body
        
        if let avatarUrl = data.creator.avatar.thumbnail.url {
            self.avatar.af_setImage(withURL: URL(string: avatarUrl)!)
        }
        
        if let url = data.image?.large?.url {
            imagejJanpol.isHidden = false
            consImageWidth.constant = 80.0
            imagejJanpol.show(fromURL: url)
            
        } else {
            imagejJanpol.isHidden = true
            consImageWidth.constant = 0.0
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
