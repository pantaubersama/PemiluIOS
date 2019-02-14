//
//  LawanDebatCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class LawanDebatCell: UITableViewCell {
    
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var lineStatus: UIView!
    @IBOutlet weak var btnHint: UIButton!
    @IBOutlet weak var containerRadionSymbolic: UIView!
    @IBOutlet weak var containerRadioTwitter: UIView!
    
    @IBOutlet weak var btnSymbolic: UIButton!
    @IBOutlet weak var ivSymboliic: CircularUIImageView!
    @IBOutlet weak var ivStatusSymbolic: UIImageView!
    @IBOutlet weak var lblStatusSymbolic: UILabel!
    
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var ivTwitter: CircularUIImageView!
    @IBOutlet weak var ivStatusTwitter: UIImageView!
    @IBOutlet weak var lblStatusTwitter: UILabel!
    
    
    private var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
    
}


extension LawanDebatCell: IReusableCell {
    
    struct Input {
        let viewModel: TantanganChallengeViewModel
        let status: Bool
    }
    
    func configure(item: Input) {
        let bag = DisposeBag()
        
        
        disposeBag = bag
    }
    
}
