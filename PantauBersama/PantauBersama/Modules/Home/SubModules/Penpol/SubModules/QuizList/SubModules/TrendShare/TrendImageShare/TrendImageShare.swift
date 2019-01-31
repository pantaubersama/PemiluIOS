//
//  TrendImageShare.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Networking
import Common

class TrendImageShare: UIView {
    
    @IBOutlet weak var lblResultSummary: Label!
    @IBOutlet weak var lblResultKecenderungan: Label!
    @IBOutlet weak var ivPaslon: UIImageView!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblPaslon: UILabel!
   
    override init(frame: CGRect) {
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
    }
    
    func configure(data: TrendResponse) {
        let kecenderungan = data.teams.max { $0.percentage?.isLess(than: $1.percentage ?? 0.0) ?? false }
        
        if let avatarUrl = kecenderungan?.team.avatar {
            self.ivPaslon.show(fromURL: avatarUrl)
        }
        self.lblResultSummary.text = "Total Kecenderunganmu \(data.meta.quizzes.finished) dari \(data.meta.quizzes.total) Quiz,"
        self.lblResultKecenderungan.text = "\(data.user.fullName ?? "") lebih suka jawaban dari Paslon no \(kecenderungan?.team.id ?? 0)"
        let percentage = String(format: "%.0f", kecenderungan?.percentage ?? 0.0) + "%"
        self.lblPercentage.text = percentage
        self.lblPaslon.text = "\(kecenderungan?.team.title ?? "")"
    }
}
