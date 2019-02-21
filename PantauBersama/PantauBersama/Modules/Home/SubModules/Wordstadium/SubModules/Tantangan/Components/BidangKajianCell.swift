
//
//  BidangKajianCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class BidangKajianCell: UITableViewCell {
    
    @IBOutlet weak var lineStatus: UIView!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var hintKajian: UIButton!
    @IBOutlet weak var btnKajian: UIButton!
    @IBOutlet weak var tagKajian: UIPaddedLabel!
    @IBOutlet weak var statusBottom: UIImageView!
    
    var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension BidangKajianCell: IReusableCell {
    
    struct Input {
        let viewModel: TantanganChallengeViewModel
        let status: Bool
        let nameKajian: String?
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        lineStatus.backgroundColor = item.status ? #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1) : #colorLiteral(red: 0.7960169315, green: 0.7961130738, blue: 0.7959839106, alpha: 1)
        status.image = item.status ? #imageLiteral(resourceName: "checkDone") : #imageLiteral(resourceName: "checkUnactive")
        statusBottom.image = item.status ? nil : #imageLiteral(resourceName: "checkInactive")
        
        if item.status == true {
            tagKajian.isHidden = false
            btnKajian.isHidden = true
        } else {
            tagKajian.isHidden = true
            btnKajian.isHidden = false
        }
        
        tagKajian.text = item.nameKajian
        tagKajian.layer.borderColor = #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1)
        tagKajian.layer.borderWidth = 1.0
        tagKajian.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer()
        tagKajian.addGestureRecognizer(tap)
        
        tap.rx.event
            .mapToVoid()
            .bind(to: item.viewModel.input.kajianButtonI)
            .disposed(by: bag)
        
        btnKajian.rx.tap
            .bind(to: item.viewModel.input.kajianButtonI)
            .disposed(by: bag)
        
        hintKajian.rx.tap
            .bind(to: item.viewModel.input.hintKajianI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
}
