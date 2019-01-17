//
//  BannerInfoViewCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import Networking

typealias BannerInfoViewCellConfigurator = CellConfigurator<BannerInfoViewCell, BannerInfoViewCell.Input>

class BannerInfoViewCell: UITableViewCell {

    
    @IBOutlet weak var ivInfoBackground: UIImageView!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var tvTitle: Label!
    @IBOutlet weak var tvDescription: UITextView!
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
}

extension BannerInfoViewCell: IReusableCell {
    
    struct Input {
        let bannerInfo: BannerInfo
    }
    
    func configureCell(item: Input) {
        
        switch item.bannerInfo.pageName {
        case .tanya:
            ivInfoBackground.image = UIImage(named: "icAskInfoHeader")
        case .kuis:
            ivInfoBackground.image = UIImage(named: "icQuizInfoHeader")
        case .janji_politik:
            ivInfoBackground.image = UIImage(named: "icJanpolInfoHeader")
        case .pilpres:
            ivInfoBackground.image = UIImage(named: "icPilpresInfoHeader")
        case .unknown:
            return
        }
        
        tvTitle.text = item.bannerInfo.pageName.title
        tvDescription.text =  item.bannerInfo.body
        
        tvDescription.textContainer.lineBreakMode = .byWordWrapping
        tvDescription.isScrollEnabled = false
        
        if let imageUrl = item.bannerInfo.image.large?.url {
            ivImage.af_setImage(withURL: URL(string: imageUrl)!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.3), completion: { (response) in
                if let image = response.result.value{
                    DispatchQueue.main.async {
                        let aspectRatio = image.size.width / image.size.height
                        let newHeight = self.ivImage.frame.width / aspectRatio
                        self.ivImage.frame.size = CGSize(width: self.ivImage.frame.width, height: newHeight)
                    }
                }
            })
        }
        
    }
    
}
