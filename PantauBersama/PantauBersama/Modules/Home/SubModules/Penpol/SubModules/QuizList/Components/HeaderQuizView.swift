//
//  HeaderQuizView.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class HeaderQuizView: UIView {
    private let disposeBag: DisposeBag = DisposeBag()
    let trendHeaderView = TrendHeaderView()
    
    func config(viewModel: QuizViewModel) {
        let bannerInfoQuizView = BannerHeaderView()
        trendHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bannerInfoQuizView)
        addSubview(trendHeaderView)
        
        print("HAhahaha banner: \(bannerInfoQuizView.frame.height)")
        print("HAhahaha trend: \(trendHeaderView.frame.height)")
        
        NSLayoutConstraint.activate([
            // MARK: constraint bannerInfoAskView
            bannerInfoQuizView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bannerInfoQuizView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bannerInfoQuizView.topAnchor.constraint(equalTo: self.topAnchor),
            bannerInfoQuizView.bottomAnchor.constraint(equalTo: trendHeaderView.topAnchor),
            bannerInfoQuizView.heightAnchor.constraint(equalToConstant: 115),
            
            // MARK: constraint trendHeaderView
            trendHeaderView.topAnchor.constraint(equalTo: bannerInfoQuizView.bottomAnchor),
            trendHeaderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            trendHeaderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            trendHeaderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            trendHeaderView.heightAnchor.constraint(equalToConstant: 0)
            ])
        
        trendHeaderView.isHidden = true
        
        viewModel.output.bannerInfo
            .drive(onNext: { (banner) in
                bannerInfoQuizView.config(banner: banner, viewModel: viewModel.headerViewModel)
            })
            .disposed(by: disposeBag)
        
        trendHeaderView.shareButton.rx.tap
            .bind(to: viewModel.input.shareTrendTrigger)
            .disposed(by: self.disposeBag)
    }
    
    
}
