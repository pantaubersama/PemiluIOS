//
//  HeaderEditProfile.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking
import AlamofireImage
import RxSwift

class HeaderEditProfile: UIView {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var buttonGanti: UIButton!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func configure(data: User) {
        if let thumbnailMedium = data.avatar.mediumSquare.url {
            avatar.af_setImage(withURL: URL(string: thumbnailMedium)!)
        }
    }
}
