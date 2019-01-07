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
    private var viewModel: QuizViewModel?
    private let disposeBag: DisposeBag = DisposeBag()
    
    convenience init(viewModel: QuizViewModel) {
        self.init()
        self.viewModel = viewModel
        setup()
    }

    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 115)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        guard let viewModel = self.viewModel else { return }
        
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
            
            // MARK: constraint trendHeaderView
            trendHeaderView.topAnchor.constraint(equalTo: bannerInfoQuizView.bottomAnchor),
            trendHeaderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            trendHeaderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            trendHeaderView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        
        trendHeaderView.isHidden = true
        
        viewModel.output.bannerInfo
            .drive(onNext: { (banner) in
                bannerInfoQuizView.config(banner: banner, viewModel: viewModel.headerViewModel)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.totalResult
            .drive(onNext: { (result) in
                if result.meta.quizzes.finished >= 1 {
                    trendHeaderView.isHidden = false
                    self.frame.size.height = 325
                    
                    trendHeaderView.config(result: result, viewModel: viewModel)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
}
