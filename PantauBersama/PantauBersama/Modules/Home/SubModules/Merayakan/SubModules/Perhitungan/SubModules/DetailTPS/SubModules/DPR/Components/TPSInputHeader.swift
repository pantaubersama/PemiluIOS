//
//  TPSInputHeader.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

class TPSInputHeader: UIView {

    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var lblNameParty: Label!
    @IBOutlet weak var lblNumberParty: Label!
    private(set) var disposeBag: DisposeBag?
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 78.0)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivLogo.image = nil
        ivLogo.af_cancelImageRequest()
    }
    
    private func setup() {
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func configure(header: String, number: Int, logo: String) {
        ivLogo.af_setImage(withURL: URL(string: logo)!)
        lblNameParty.text = header
        lblNumberParty.text = "No urut \(number)"
    }
    
}
