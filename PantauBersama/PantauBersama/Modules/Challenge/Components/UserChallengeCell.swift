//
//  UserChallengeCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import Networking

class UserChallengeCell: UITableViewCell {
    
    
    @IBOutlet weak var avatar: CircularUIImageView!
    @IBOutlet weak var lblName: Label!
    @IBOutlet weak var lblUsername: Label!
    @IBOutlet weak var btnConfirm: Button!
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnConfirm.isHidden = true
    }
 
}

extension UserChallengeCell: IReusableCell {
    
    struct Input {
        let audience: Audiences
        let viewModel: ChallengeViewModel
        let isMyChallenge: Bool
        let isExpired: Bool
    }
    
    func configureCell(item: Input) {
        avatar.show(fromURL: item.audience.avatar?.url ?? "")
        lblName.text = item.audience.fullName
        lblUsername.text = item.audience.username
        btnConfirm.isHidden = !item.isMyChallenge
        
        btnConfirm.rx.tap
            .map({ item.audience.id })
            .bind(to: item.viewModel.input.confirmOpponentI)
            .disposed(by: disposeBag)
        
        item.viewModel.output
            .confirmOpponentO
            .drive()
            .disposed(by: disposeBag)

        /// Force button confirm
        btnConfirm.isEnabled = !item.isExpired
        btnConfirm.backgroundColor = item.isExpired ? #colorLiteral(red: 0.9254901961, green: 0.9254901961, blue: 0.9254901961, alpha: 1) : #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1)
    }
    
    func configure(data: SearchUserModel) {
        if let url = data.avatar {
            self.avatar.show(fromURL: url)
        }
        lblName.text = data.fullName
        lblUsername.text = data.screenName
    }
}
