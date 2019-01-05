//
//  TrendHeaderView.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import UIKit
import Common
import RxSwift
import RxCocoa

class TrendHeaderView: UIView {

    @IBOutlet weak var ivPaslon: UIImageView!
    @IBOutlet weak var lbTotal: Label!
    @IBOutlet weak var lbKecenderungan: Label!
    @IBOutlet weak var shareButton: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    private var viewModel: QuizViewModel?
    
    // TODO: change to trend model
    var trend: Any! {
        didSet {
            // TODO: view configuration
        }
    }
    
    convenience init(viewModel: QuizViewModel) {
        self.init()
        self.viewModel = viewModel
        
        setup()
    }
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 210)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        disposeBag = DisposeBag()
        
        guard let viewModel = self.viewModel else { return }
        
        shareButton.rx.tap
            .map({ self.trend })
            .bind(to: viewModel.input.shareTrendTrigger)
            .disposed(by: disposeBag)
    
    }

}
