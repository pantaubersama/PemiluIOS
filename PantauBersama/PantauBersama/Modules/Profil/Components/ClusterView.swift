//
//  ClusterView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking
import AlamofireImage

class ClusterView: UIView {
    
    @IBOutlet weak var viewCluster: UIStackView!
    @IBOutlet weak var viewNoCluster: UIStackView!
    @IBOutlet weak var iconCluster: UIImageView!
    @IBOutlet weak var nameCluster: Label!
    @IBOutlet weak var moreCluster: UIButton!
    @IBOutlet weak var buttonReqCluster: Button!
    @IBOutlet weak var labelReqCluster: Label!
    
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
    
    func configure(data: User, isMyAccount: Bool) {
        
        if data.cluster != nil {
            viewNoCluster.isHidden = true
            buttonReqCluster.isHidden = true
            labelReqCluster.isHidden = true
            nameCluster.text = data.cluster?.name
            if let thumbnail = data.cluster?.image?.thumbnail.url {
                iconCluster.af_setImage(withURL: URL(string: thumbnail)!)
            }
            
            
        } else {
            viewCluster.isHidden = true
            iconCluster.isHidden = true
            nameCluster.isHidden = true
            moreCluster.isHidden = true
            
        }
    }
    
}
