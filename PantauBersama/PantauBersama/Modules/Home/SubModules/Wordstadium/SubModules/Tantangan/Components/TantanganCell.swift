//
//  TantanganCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Common

typealias TantanganCellConfigured = CellConfigurator<TantanganCell, TantanganCell.Input>

class TantanganCell: UITableViewCell {
    
    
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var lineCheck: UIView!
    @IBOutlet weak var lblHeader: Label!
    @IBOutlet weak var hintImage: UIImageView!
    @IBOutlet weak var lblDesc: Label!
    @IBOutlet weak var container: UIView!
    
    var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
    
}

extension TantanganCell: IReusableCell {
    
    struct Input {
        let data: TantanganData
        let active: Bool
    }
    
    func configureCell(item: Input) {
        lblHeader.text = item.data.title
        lblDesc.text = item.data.subtitle
        checkImage.image = item.active ? #imageLiteral(resourceName: "checkDone") : #imageLiteral(resourceName: "checkUnactive")
        lineCheck.backgroundColor = item.active ? #colorLiteral(red: 1, green: 0.6921681166, blue: 0, alpha: 1) : #colorLiteral(red: 0.7960169315, green: 0.7961130738, blue: 0.7959839106, alpha: 1)
    }
    
}
