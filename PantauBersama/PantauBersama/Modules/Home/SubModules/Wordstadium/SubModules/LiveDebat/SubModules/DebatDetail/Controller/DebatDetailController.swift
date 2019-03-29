//
//  DebatDetailController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 18/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking
import AlamofireImage

class DebatDetailController: UIViewController {
    
    var viewModel: DebatDetailViewModel!
    @IBOutlet weak var btnClose: ImageButton!
    @IBOutlet weak var viewChallengeDetail: ChallengeDetailView!
    @IBOutlet weak var viewFooterProfileView: FooterProfileView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnClose.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.challengeO
            .drive(onNext: { [unowned self]challenge in
                self.configureChallengeDetail(challenge: challenge)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureChallengeDetail(challenge: Challenge) {
        self.viewChallengeDetail.lblSaldo.text = "\(challenge.timeLimit ?? 0) menit"
        self.viewChallengeDetail.lblTag.text = challenge.topic?.first ?? ""
        self.viewChallengeDetail.lblStatement.text = challenge.statement
        self.viewChallengeDetail.lblDate.text = challenge.showTimeAt?.date
        self.viewChallengeDetail.lblTime.text = challenge.showTimeAt?.time
        
        self.viewFooterProfileView.ivAvatar.af_setImage(withURL: URL(string: challenge.challenger?.avatar?.url ?? "")!)
        self.viewFooterProfileView.lblName.text = challenge.challenger?.fullName ?? ""
        self.viewFooterProfileView.lblStatus.text = challenge.challenger?.about ?? ""
        self.viewFooterProfileView.lblPostTime.text = challenge.createdAt?.date ?? ""
    }
}
