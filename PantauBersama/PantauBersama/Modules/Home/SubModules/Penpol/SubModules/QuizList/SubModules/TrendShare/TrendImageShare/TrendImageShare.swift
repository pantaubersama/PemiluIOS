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

enum ImageShareType {
    case trend
    case quiz
}

class TrendImageShare: UIView {
    
    @IBOutlet weak var lblResultSummary: Label!
    @IBOutlet weak var lblResultKecenderungan: Label!
    @IBOutlet weak var ivPaslon: UIImageView!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblPaslon: UILabel!
    @IBOutlet weak var background: UIImageView!
    
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
        let trendHalf = String(format: "%0.f", kecenderungan?.percentage ?? 0.0)
        let kecenderunganRandom = data.teams.randomElement()
        if trendHalf == "50" {
            if let avatarUrl = kecenderunganRandom?.team.avatar {
                self.ivPaslon.af_setImage(withURL: URL(string: avatarUrl)!)
            }
            self.lblResultSummary.text = "Total Kecenderunganmu \(data.meta.quizzes.finished) dari \(data.meta.quizzes.total) Quiz,"
            self.lblResultKecenderungan.text = "\(data.user.fullName ?? "") lebih suka jawaban dari Paslon no \(kecenderunganRandom?.team.id ?? 0)"
            let percentage = String(format: "%.0f", kecenderunganRandom?.percentage ?? 0.0) + "%"
            self.lblPercentage.text = percentage
            self.lblPaslon.text = "\(kecenderunganRandom?.team.title ?? "")"
        } else if trendHalf == "0" {
            if let avatarUrl = kecenderunganRandom?.team.avatar {
                self.ivPaslon.af_setImage(withURL: URL(string: avatarUrl)!)
            }
            self.lblResultSummary.text = "Total Kecenderunganmu \(data.meta.quizzes.finished) dari \(data.meta.quizzes.total) Quiz,"
            self.lblResultKecenderungan.text = "\(data.user.fullName ?? "") lebih suka jawaban dari Paslon no \(kecenderunganRandom?.team.id ?? 0)"
            let percentage = String(format: "%.0f", kecenderunganRandom?.percentage ?? 0.0) + "%"
            self.lblPercentage.text = percentage
            self.lblPaslon.text = "\(kecenderunganRandom?.team.title ?? "")"
        } else {
            if let avatarUrl = kecenderungan?.team.avatar {
                self.ivPaslon.af_setImage(withURL: URL(string: avatarUrl)!)
            }
            self.lblResultSummary.text = "Total Kecenderunganmu \(data.meta.quizzes.finished) dari \(data.meta.quizzes.total) Quiz,"
            self.lblResultKecenderungan.text = "\(data.user.fullName ?? "") lebih suka jawaban dari Paslon no \(kecenderungan?.team.id ?? 0)"
            let percentage = String(format: "%.0f", kecenderungan?.percentage ?? 0.0) + "%"
            self.lblPercentage.text = percentage
            self.lblPaslon.text = "\(kecenderungan?.team.title ?? "")"
        }
    }
    
    func configureResult(data: QuizResultModel) {
        self.ivPaslon.show(fromURL: data.avatar)
        self.lblPaslon.text = data.name
        self.lblPercentage.text = data.percentage
        self.lblResultSummary.text = "Dari hasil pilihan di Quiz \(data.nameQuiz),"
        self.lblResultKecenderungan.text = "\(data.userName) lebih suka jawaban dari Paslon no \(data.paslonNo)"
    }
    
    func configureBackground(type: ImageShareType) {
        switch type {
        case .trend:
            self.background.image = #imageLiteral(resourceName: "trendBackground")
        case .quiz:
            self.background.image = #imageLiteral(resourceName: "quizResultUngu")
        }
    }
    
}
