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
    
    private(set) var disposeBag = DisposeBag()
    
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
        disposeBag = DisposeBag()
        btnVote.suara = 0
    }
}

extension TPSInputCell: IReusableCell {
    
    struct Input {
        let candidates: CandidateActor
        let viewModel: DetailTPSDPRViewModel
        let indexPath: IndexPath
    }
    /// IKI RA KANGGO
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        lblNameCandidatees.text = "\(item.candidates.number). \(item.candidates.name)"
        
        btnVote.suara = item.candidates.value

        btnVote.rx_suara
            .skip(1)
            .map({ CandidatePartyCount(id: item.candidates.id, totalVote: $0, indexPath: item.indexPath)})
            .bind(to: item.viewModel.input.counterI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
    func configureDPD(item: CandidateActor) {
        lblNameCandidatees.text = "\(item.number). \(item.name)"
        btnVote.suara = item.value
    }
    
}
