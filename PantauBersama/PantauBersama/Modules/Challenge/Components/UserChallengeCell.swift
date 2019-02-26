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

class UserChallengeCell: UITableViewCell {
    
    @IBOutlet weak var avatar: CircularUIImageView!
    @IBOutlet weak var lblName: Label!
    @IBOutlet weak var lblUsername: Label!
    @IBOutlet weak var btnConfirm: Button!
    private(set) var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnConfirm.isHidden = true
    }
    
}

extension UserChallengeCell: IReusableCell {
    
    struct Input {
        
    }
    
    func configureCell(item: Input) {
        
    }
    
    func configure(data: SearchUserModel) {
        if let url = data.avatar {
            self.avatar.show(fromURL: url)
        }
        lblName.text = data.fullName
        lblUsername.text = data.screenName
    }
}
