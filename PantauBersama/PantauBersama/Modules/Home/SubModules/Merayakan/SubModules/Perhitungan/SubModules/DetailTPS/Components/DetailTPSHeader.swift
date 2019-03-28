//
//  DetailTPSHeader.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 28/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking
import RxSwift
import RxCocoa

class DetailTPSHeader: UITableViewCell, IReusableCell {
    @IBOutlet weak var lblTitle: Label!
    @IBOutlet weak var lblProvinsi: Label!
    @IBOutlet weak var lblKota: Label!
    @IBOutlet weak var lblKecamatan: Label!
    @IBOutlet weak var lblDesa: Label!
    @IBOutlet weak var btnOption: Button!
    
    
    private(set) var disposeBag: DisposeBag?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
    
}

extension DetailTPSHeader {
    
    struct Input {
        var viewModel: DetailTPSViewModel
        var data: RealCount
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        lblTitle.text = "TPS \(item.data.tps)"
        lblProvinsi.text = item.data.province.name
        lblKota.text = item.data.regency.name
        lblKecamatan.text = item.data.district.name
        lblDesa.text = item.data.village.name
        
        disposeBag = bag
    }
    
}
