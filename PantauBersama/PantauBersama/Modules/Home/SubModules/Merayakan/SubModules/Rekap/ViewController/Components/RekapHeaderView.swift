//
//  RekapHeaderView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RekapHeaderView: UIView {
    private let disposeBag: DisposeBag = DisposeBag()
    let suaraCapresView = SuaraCapresViewCell()
    
    func config(viewModel: RekapViewModel) {
        let bannerInfoView = BannerHeaderView()
        suaraCapresView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bannerInfoView)
        addSubview(suaraCapresView)
        
        NSLayoutConstraint.activate([
            // MARK: - Constraint banner
            bannerInfoView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bannerInfoView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bannerInfoView.topAnchor.constraint(equalTo: self.topAnchor),
            bannerInfoView.bottomAnchor.constraint(equalTo: suaraCapresView.topAnchor),
            bannerInfoView.heightAnchor.constraint(equalToConstant: 115),
            // MARK: - Constraint Rekap Suara
            suaraCapresView.topAnchor.constraint(equalTo: bannerInfoView.bottomAnchor),
            suaraCapresView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            suaraCapresView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            suaraCapresView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        viewModel.output.contributionsO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                self.suaraCapresView.lblParticipant.text = "\(response.total)"
                self.suaraCapresView.lblUpdated.text = "Pembaruan terakhir pukul " + response.lastUpdate.createdInWord.id
            })
            .disposed(by: disposeBag)
        
        viewModel.output.summaryPresidentO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let candidate1 = response.percentage?.candidates?.filter({ $0.id == 1 }).first
                let candidate2 = response.percentage?.candidates?.filter({ $0.id == 2 }).first
                let percentageSatuFormat = String(format: "%.2f", candidate1?.percentage ?? 0.0)
                let percentageDuaFormat = String(format: "%.2f", candidate2?.percentage ?? 0.0)
                self.suaraCapresView.lblPaslonSatuPercentage.text = percentageSatuFormat
                self.suaraCapresView.lblPaslonDuaPercentage.text = percentageDuaFormat
                print("Float number : \(Float(candidate1?.percentage ?? 0.0))")
                self.suaraCapresView.progressView.setProgress(Float(candidate1?.percentage ?? 0.0) / 100, animated: true)
                self.suaraCapresView.lblRerataSatu.text = "Rerata \(candidate1?.totalVote ?? 0) suara"
                self.suaraCapresView.lblRerataDua.text = "Rerata \(candidate2?.totalVote ?? 0) suara"
            })
            .disposed(by: disposeBag)
    }
    
}
