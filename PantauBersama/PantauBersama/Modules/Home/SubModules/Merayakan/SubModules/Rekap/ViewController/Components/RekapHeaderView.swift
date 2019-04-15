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
import Common

class RekapHeaderView: UIView {
    private let disposeBag: DisposeBag = DisposeBag()
    let suaraCapresView = SuaraCapresViewCell()
    
    func config(viewModel: RekapViewModel, tableView: UITableView) {
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
                self.suaraCapresView.lblUpdated.text = "Pembaruan terakhir " + response.lastUpdate.createdInWord.id
                
                if response.total != 0 {
                    tableView.backgroundView = nil
                    tableView.tableHeaderView?.isHidden = false
                    tableView.tableFooterView?.isHidden = false
                    tableView.isScrollEnabled = true
                }
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
                /// Need configure track tint is for candidates 2
                /// progress tint is for candidatees 1
                /// check percentage first if 0.00 %
                if response.percentage?.candidates == nil {
                    self.suaraCapresView.progressView.isHidden = true
                } else {
                    self.suaraCapresView.progressView.isHidden = false
                    self.suaraCapresView.progressView.trackTintColor = Color.RGBColor(red: 242, green: 119, blue: 29)
                    self.suaraCapresView.progressView.progressTintColor = Color.RGBColor(red: 155, green: 0, blue: 18)
                    self.suaraCapresView.progressView.setProgress(Float(candidate1?.percentage ?? 0.0) / 100, animated: true)
                    self.suaraCapresView.lblRerataSatu.text = "Rata-rata \(candidate1?.totalVote ?? 0) suara"
                    self.suaraCapresView.lblRerataDua.text = "Rata-rata \(candidate2?.totalVote ?? 0) suara"
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.bannerInfoO
            .drive(onNext: { (bannerInfo) in
                bannerInfoView.config(banner: bannerInfo, viewModel: viewModel.headerViewModel)
            })
            .disposed(by: disposeBag)
    }
    
}
