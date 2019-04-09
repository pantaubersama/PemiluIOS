//
//  C1SummaryFormView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

enum TypeTitleFormC1 {
    case pemilihDPT
    case pemilihDPTb
    case pemilihDPK
    case totalPemilihA1A3
    case hakDPT
    case hakDPTb
    case hakDPK
    case totalHakB1B3
    case disabilitasTotal
    case disabilitasHak
}

@IBDesignable
class C1SummaryFormView: UIView {
    
    @IBOutlet weak var lblTitle: Label!
    @IBOutlet weak var lblLaki: Label!
    @IBOutlet weak var lblPerempuan: Label!
    @IBOutlet weak var lblTotal: Label!
    
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
    
    func configure(typeTitle: TypeTitleFormC1) {
        switch typeTitle {
        case .pemilihDPT:
            self.lblTitle.text = "1. Jumlah Pemilih dalam DPT (Model A.3-KPU)"
        case .pemilihDPTb:
            self.lblTitle.text = "2. Jumlah Pemilih dalam DPTb (Model A-4 KPU)"
        case .pemilihDPK:
            self.lblTitle.text = "3. Jumlah Pemilih dalam DPK ( Model A.DPK-KPU)"
        case .totalPemilihA1A3:
            self.lblTitle.text = "4. Jumlah Pemilih (A.1 + A.2 + A.3)"
        case .hakDPT:
            self.lblTitle.text = "1. Jumlah pengguna hak pilih dalam DPT (Model C7.DPT-KPU)"
        case .hakDPTb:
            self.lblTitle.text = "2. Jumlah pengguna hak pilih dalam DPTb (Model C7.DPTb-KPU)"
        case .hakDPK:
            self.lblTitle.text = "3. Jumlah pengguna hak pilih dalam DPK (Model C7.DPK-KPU)"
        case .totalHakB1B3:
            self.lblTitle.text = "4.  Jumlah Pengguna Hak Pilih (B.1 + B.2 + B.3)"
        case .disabilitasTotal:
            self.lblTitle.text = "1. Jumlah seluruh Pemilih disabilitas terdaftar dalam DPT, DPTb dan DPK"
        case .disabilitasHak:
            self.lblTitle.text = "2. Jumlah seluruh Pemilih disabilitas yang menggunakan hak pilih"
        }
    }
    
}
