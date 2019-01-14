//
//  File.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 29/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class HeaderAskView: UIView {
    private var viewModel: IQuestionListViewModel?
    private let disposeBag: DisposeBag = DisposeBag()
    
    convenience init(viewModel: IQuestionListViewModel) {
        self.init()
        self.viewModel = viewModel
        setup()
    }
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 177)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        guard let viewModel = self.viewModel else { return }
        
        let bannerInfoAskView = BannerHeaderView()
        bannerInfoAskView.translatesAutoresizingMaskIntoConstraints = false
        
        let createAskHeaderView = CreateAskHeaderView(viewModel: viewModel)
        createAskHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bannerInfoAskView)
        addSubview(createAskHeaderView)
        
        NSLayoutConstraint.activate([
            // MARK: constraint bannerInfoAskView
            bannerInfoAskView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bannerInfoAskView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bannerInfoAskView.topAnchor.constraint(equalTo: self.topAnchor),
            bannerInfoAskView.heightAnchor.constraint(equalToConstant: 85),
            
            // MARK: constraint createAskHeaderView
            createAskHeaderView.topAnchor.constraint(equalTo: bannerInfoAskView.bottomAnchor),
            createAskHeaderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            createAskHeaderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            createAskHeaderView.heightAnchor.constraint(equalToConstant: 85)
            ])
        
        viewModel.output.bannerO
            .drive(onNext: { (banner) in
                bannerInfoAskView.config(banner: banner, viewModel: viewModel.headerViewModel)
            })
            .disposed(by: disposeBag)
    }
    
    
}
