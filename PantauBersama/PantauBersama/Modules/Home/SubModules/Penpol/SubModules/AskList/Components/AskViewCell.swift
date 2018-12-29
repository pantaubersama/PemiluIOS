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

typealias AskViewCellConfigurator = CellConfigurator<AskViewCell, AskViewCell.Input>

class AskViewCell: UITableViewCell, IReusableCell  {
    struct Input {
        let viewModel: AskViewModel
        let question: QuestionModel
    }

    private(set) var disposeBag = DisposeBag()
    
    @IBOutlet weak var lbBody: Label!
    @IBOutlet weak var lbCreatedAt: Label!
    @IBOutlet weak var lbAbout: Label!
    @IBOutlet weak var lbFullname: Label!
    @IBOutlet weak var ivAvatar: UIImageView!
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
    
    func configureCell(item: Input) {
        ivAvatar.show(fromURL: item.question.user.avatar.thumbnailSquare.url)
        lbFullname.text = item.question.user.firstName + " " + item.question.user.lastName
        lbAbout.text = item.question.user.about
        lbBody.text = item.question.body
        lbCreatedAt.text = item.question.createdAt.id
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
