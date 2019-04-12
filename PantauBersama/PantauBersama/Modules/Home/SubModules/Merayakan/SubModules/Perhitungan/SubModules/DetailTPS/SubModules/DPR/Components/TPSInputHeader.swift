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

class TPSInputHeader: UITableViewCell {
    
    
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lblName: Label!
    @IBOutlet weak var lblSerialNumber: Label!
    @IBOutlet weak var btnSuara: TPSButton!
    
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivImage.af_cancelImageRequest()
        ivImage.image = nil
        disposeBag = DisposeBag()
    }
}

extension TPSInputHeader: IReusableCell {
    struct Input {
        let name: String
        let section: Int
        let number: Int
        let logo: String
        let viewModel: DetailTPSDPRViewModel
        let headerCount: Int
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        ivImage.af_setImage(withURL: URL(string: item.logo)!)
        
        lblName.text = item.name
        lblSerialNumber.text = "No Urut " + "\(item.number)"
        
        btnSuara.suara = item.headerCount
        
        btnSuara
            .rx_suara
            .skip(1)
            .distinctUntilChanged({ (a, b) -> Bool in
                return a != b
            })
            .map({ PartyCount(section: item.section, number: item.number, value: $0) })
            .bind(to: item.viewModel.input.counterPartyI)
            .disposed(by: bag)
        
        disposeBag = bag
        
    }
}
