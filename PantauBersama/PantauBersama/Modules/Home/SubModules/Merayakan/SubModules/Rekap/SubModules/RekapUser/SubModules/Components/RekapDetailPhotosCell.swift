//
//  RekapDetailPhotosCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

class RekapDetailPhotosCell: UITableViewCell {
    @IBOutlet weak var ivRekapImage: UIImageView!
    @IBOutlet weak var lblRekap: Label!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivRekapImage.af_cancelImageRequest()
        ivRekapImage.image = nil
    }
    
}

extension RekapDetailPhotosCell: IReusableCell {
    
    struct Input {
        let data: ImageResponse
        let title: String
    }
    
    func configureCell(item: Input) {
        if let images = item.data.file.thumbnail.url {
            ivRekapImage.af_setImage(withURL: URL(string: images)!)
        }
        lblRekap.text = item.title
    }
}
