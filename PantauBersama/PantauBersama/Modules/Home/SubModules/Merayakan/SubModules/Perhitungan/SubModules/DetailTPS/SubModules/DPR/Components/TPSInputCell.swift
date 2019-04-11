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
        btnVote.suara = 0
    }
}

extension TPSInputCell: IReusableCell {
    
    struct Input {
        let candidates: CandidateActor
        let viewModel: DetailTPSDPRViewModel
        let indexPath: IndexPath
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        lblNameCandidatees.text = item.candidates.name
        
        btnVote.suara = item.candidates.value
        
//        /// Purpose for initial value
//        for itemActor in item.viewModel.bufferItemActor.value {
//            if itemActor.actorId == "\(item.candidates.id)" {
//                btnVote.suara = itemActor.totalVote ?? 0
//            } else {
//                btnVote.suara = 0
//            }
//        }
//
//        for candidates in item.viewModel.candidatesPartyValue.value {
//            if candidates.id == item.candidates.id {
//                btnVote.suara = candidates.totalVote
//            } else {
//                btnVote.suara = 0
//            }
//        }
    
        
        btnVote.rx_suara
            .skip(1)
            .map({ CandidatePartyCount(id: item.candidates.id, totalVote: $0, indexPath: item.indexPath)})
            .bind(to: item.viewModel.input.counterI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
    func configureDPD(item: CandidateActor) {
        lblNameCandidatees.text = item.name
    }
    
}
