//
//  TPSInputCell.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking
import RxSwift
import RxCocoa

class TPSInputCell: UITableViewCell {

    @IBOutlet weak var lblNameCandidatees: Label!
    @IBOutlet weak var btnVote: TPSButton!
    
    private(set) var disposeBag: DisposeBag?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
}

extension TPSInputCell: IReusableCell {
    
    struct Input {
        let candidates: Candidates
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        lblNameCandidatees.text = item.candidates.name ?? ""
        
        disposeBag = bag
    }
    
}
