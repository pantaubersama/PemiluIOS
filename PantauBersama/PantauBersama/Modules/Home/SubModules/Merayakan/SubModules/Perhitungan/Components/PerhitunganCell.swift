//
//  PerhitunganCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

typealias PerhitunganCellConfigured = CellConfigurator<PerhitunganCell, PerhitunganCell.Input>
class PerhitunganCell: UITableViewCell {
    @IBOutlet weak var tpsNameLbl: Label!
    @IBOutlet weak var moreButton: ImageButton!
    @IBOutlet weak var provinceLbl: Label!
    @IBOutlet weak var regencyLbl: Label!
    @IBOutlet weak var districtLbl: Label!
    @IBOutlet weak var vilageLbl: Label!
    @IBOutlet weak var tpsStatusLbl: UILabel!
    @IBOutlet weak var tpsStatusView: RoundView!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
}

extension PerhitunganCell: IReusableCell {
    
    struct Input {
        let viewModel: PerhitunganViewModel
        let data: RealCount
    }
    
    func configureCell(item: Input) {
        let feeds = item.data
        let bag = DisposeBag()
        
        configure(data: feeds)
        
        moreButton.rx.tap
            .map({ feeds })
            .bind(to: item.viewModel.input.moreTrigger)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
    func configure(data: RealCount) {
        tpsNameLbl.text = "TPS \(data.tps)"
        tpsStatusLbl.text = data.status
        provinceLbl.text = data.province.name
        regencyLbl.text = data.regency.name
        districtLbl.text = data.district.name
        vilageLbl.text = data.village.name
        
    }
    
}
