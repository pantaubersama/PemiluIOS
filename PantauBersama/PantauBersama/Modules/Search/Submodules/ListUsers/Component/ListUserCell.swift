//
//  ListUserCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 14/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking

class ListUserCell: UITableViewCell, IReusableCell {
    struct Input {
        let user: User
    }
    @IBOutlet weak var ivAvatar: CircularUIImageView!
    
    @IBOutlet weak var lbAccount: Label!
    @IBOutlet weak var lbFullname: Label!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(item: Input) {
        lbFullname.text = item.user.fullName
        lbAccount.text = item.user.username
        ivAvatar.show(fromURL: item.user.avatar.thumbnail.url ?? "")
    }
    
}
