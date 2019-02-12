//
//  BannerInfoController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import Networking

class BannerInfoController: UIViewController {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitle: Label!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var imgInfo: UIImageView!
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var lblLink: UITextView!
    
    var viewModel: BannerInfoViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        viewModel.output.bannerInfo
            .drive(onNext: { [weak self] (data) in
                guard let `self` = self else { return }
                
                self.bindData(data: data)
            })
            .disposed(by: disposeBag)
        
        btnClose.rx.tap
            .bind(to: viewModel.input.finishTrigger)
            .disposed(by: disposeBag)
    }

    func bindData(data: BannerInfo){
        
        switch data.pageName {
        case .tanya:
            imgHeader.image = UIImage(named: "icAskInfoHeader")
        case .kuis:
            imgHeader.image = UIImage(named: "icQuizInfoHeader")
        case .janji_politik:
            imgHeader.image = UIImage(named: "icJanpolInfoHeader")
        case .pilpres:
            imgHeader.image = UIImage(named: "icPilpresInfoHeader")
        case .debat:
            imgHeader.image = UIImage(named: "icPilpresInfoHeader")
        case .tantangan:
            imgHeader.image = UIImage(named: "icPilpresInfoHeader")
        default:
            return
        }
        
        lblTitle.text = data.title // change name with API
        tvDescription.text =  data.body
        tvDescription.textContainer.lineBreakMode = .byWordWrapping
        self.container.layoutIfNeeded()
        
        let attributedString = NSMutableAttributedString(string: "www.pantaubersama.com")
        attributedString.addAttribute(.link, value: "https://pantaubersama.com", range: NSRange(location: 0, length: 21))
        lblLink.attributedText = attributedString

        if let imageUrl = data.image.large?.url {
            imgInfo.af_setImage(withURL: URL(string: imageUrl)!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.3), completion: { (response) in
                if let image = response.result.value{
                    DispatchQueue.main.async {
                        let aspectRatio = image.size.width / image.size.height
                        let newHeight = self.imgInfo.frame.width / aspectRatio
                        self.imgInfo.frame.size = CGSize(width: self.imgInfo.frame.width, height: newHeight)                        
                    }
                }
            })
        }
        
        
    }

}
