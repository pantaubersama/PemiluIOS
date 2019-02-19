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
import Networking

class TrendHeaderView: UIView {

    @IBOutlet weak var ivPaslon: UIImageView!
    @IBOutlet weak var lbTotal: Label!
    @IBOutlet weak var lbKecenderungan: Label!
    @IBOutlet weak var shareButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    // TODO: change to trend model
    var trend: Any! {
        didSet {
            // TODO: view configuration
        }
    }
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 212)
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        disposeBag = DisposeBag()
        
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func config(result: TrendResponse, viewModel: QuizViewModel) {
        // TODO
        // This trend must randomize if two result have same value in format %.0f
        let kecenderungan = result.teams.max { $0.percentage?.isLess(than: $1.percentage ?? 0.0) ?? false }
        lbKecenderungan.text = "Total Kecenderunganmu, \(result.meta.quizzes.finished) dari \(result.meta.quizzes.total) Quiz"
        
        let trendHalf = String(format: "%.0f", kecenderungan?.percentage ?? 0.0)
        if trendHalf == "50" { // this will check first, and random will play
            print("trend half accepted!, original: \(kecenderungan?.percentage ?? 0.0)")
            let kecenderunganHalf = result.teams.randomElement()
            if let avatarUrl = kecenderunganHalf?.team.avatar {
                ivPaslon.af_setImage(withURL: URL(string: avatarUrl)!)
            }
            lbTotal.text =  String(format: "%.0f", kecenderunganHalf?.percentage ?? 0.0) + "% (\(kecenderunganHalf?.team.title ?? ""))"
        } else {
            if let avatarUrl = kecenderungan?.team.avatar {
                ivPaslon.af_setImage(withURL: URL(string: avatarUrl)!)
            }
            lbTotal.text =  String(format: "%.0f", kecenderungan?.percentage ?? 0.0) + "% (\(kecenderungan?.team.title ?? ""))"
        }

    }

}
