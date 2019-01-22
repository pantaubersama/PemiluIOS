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
    
    func config(viewModel: QuizViewModel) {
        let bannerInfoQuizView = BannerHeaderView()
        bannerInfoQuizView.translatesAutoresizingMaskIntoConstraints = false
        
        let trendHeaderView = TrendHeaderView()
        trendHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bannerInfoQuizView)
        addSubview(trendHeaderView)
        
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
            trendHeaderView.heightAnchor.constraint(equalToConstant: 212),
            trendHeaderView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        
        trendHeaderView.isHidden = true
        
        viewModel.output.bannerInfo
            .drive(onNext: { (banner) in
                bannerInfoQuizView.config(banner: banner, viewModel: viewModel.headerViewModel)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.totalResult
            .do(onNext: { [unowned self] (result) in
                if result.meta.quizzes.finished >= 1 {
                    trendHeaderView.isHidden = false
                    self.frame.size.height = 327
                    
                    trendHeaderView.config(result: result, viewModel: viewModel)
                    trendHeaderView.layoutIfNeeded()
                } else {
                    self.frame.size.height = 115
                }
            })
            .drive()
            .disposed(by: disposeBag)
        
        trendHeaderView.shareButton.rx.tap
            .bind(to: viewModel.input.shareTrendTrigger)
            .disposed(by: self.disposeBag)
    }
    
    
}
