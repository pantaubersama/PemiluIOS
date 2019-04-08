//
//  RekapTPSUserCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import Networking

class RekapTPSUserCell: UITableViewCell {
    
    @IBOutlet weak var ivAvatar: CircularUIImageView!
    @IBOutlet weak var lblName: Label!
    @IBOutlet weak var lblTPS: Label!
    @IBOutlet weak var lblWilayah: Label!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivAvatar.af_cancelImageRequest()
        ivAvatar.image = #imageLiteral(resourceName: "icDummyPerson")
    }
    
}

extension RekapTPSUserCell: IReusableCell {
    
    struct Input {
        let data: RealCount
    }
    
    func configureCell(item: Input) {
        if let avatar = item.data.user?.avatar.thumbnail.url {
            self.ivAvatar.af_setImage(withURL: URL(string: avatar)!)
        }
        lblName.text = item.data.user?.fullName
        lblTPS.text = "TPS \(item.data.tps)"
        lblWilayah.text = "\(item.data.province.name), \(item.data.regency.name), \(item.data.district.name), \(item.data.village.name)"
    }
}
