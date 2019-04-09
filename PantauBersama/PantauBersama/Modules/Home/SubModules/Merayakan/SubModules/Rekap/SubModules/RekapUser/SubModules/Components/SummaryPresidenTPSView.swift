//
//  SummaryPresidenTPSView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking
import Common

class SummaryPresidenTPSView: UIView {
    
    @IBOutlet weak var ivAvatar: CircularUIImageView!
    @IBOutlet weak var lblName: Label!
    @IBOutlet weak var lblTPS: Label!
    @IBOutlet weak var lblWilayah: Label!
    @IBOutlet weak var lblPercentagePaslonSatu: Label!
    @IBOutlet weak var lblSummaryPaslonSatu: Label!
    @IBOutlet weak var lblPercentagePaslonDua: Label!
    @IBOutlet weak var lblSummaryPaslonDua: Label!
    @IBOutlet weak var lblSuaraTakSah: Label!
    @IBOutlet weak var lblSuaraSah: Label!
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 262.0)
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
    
    func configure(data: DetailSummaryPresidenResponse) {
        if let avatar = data.user?.avatar.thumbnail.url {
            self.ivAvatar.af_setImage(withURL: URL(string: avatar)!)
        }
        lblName.text = data.user?.fullName
        lblTPS.text = "\(data.tps)"
        lblWilayah.text = data.percentage.region.name
        let candidatesSatu = data.percentage.candidates?.filter({ $0.id == 1}).first
        let candidateDua = data.percentage.candidates?.filter({ $0.id == 2}).first
        lblPercentagePaslonSatu.text = "\(candidatesSatu?.percentage ?? 0.0)%"
        lblPercentagePaslonDua.text = "\(candidateDua?.percentage ?? 0.0)%"
        lblSummaryPaslonSatu.text = "| \(candidatesSatu?.totalVote ?? 0) suara"
        lblSummaryPaslonDua.text = "| \(candidateDua?.totalVote ?? 0) suara"
        lblSuaraTakSah.text = "\(data.percentage.invalidVote.totalVote)"
        lblSuaraSah.text = "\(data.percentage.totalVote)"
    }
}
