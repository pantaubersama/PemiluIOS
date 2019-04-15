//
//  C1SummaryPemilihView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking

class C1SummaryPemilihView: UIView {
    
    @IBOutlet weak var formDPT: C1SummaryFormView!
    @IBOutlet weak var formDPTb: C1SummaryFormView!
    @IBOutlet weak var formDPK: C1SummaryFormView!
    @IBOutlet weak var formTotalA1A3: C1SummaryFormView!
    
    @IBOutlet weak var formHakDPT: C1SummaryFormView!
    @IBOutlet weak var formHakDPTb: C1SummaryFormView!
    @IBOutlet weak var formHakDPK: C1SummaryFormView!
    @IBOutlet weak var formTotalB1B3: C1SummaryFormView!
    
    @IBOutlet weak var formTotalPemilihDisabilitas: C1SummaryFormView!
    @IBOutlet weak var formTotalHakDisabilitas: C1SummaryFormView!
    
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
    
    func configure(data: C1Response) {
        formDPT.configure(typeTitle: .pemilihDPT)
        formDPT.lblLaki.text = "\(data.a3Laki)"
        formDPT.lblPerempuan.text = "\(data.a3Perempuan)"
        formDPT.lblTotal.text = "\(data.aggregates.a3Total)"
        
        formDPTb.configure(typeTitle: .pemilihDPTb)
        formDPTb.lblLaki.text = "\(data.a4Laki)"
        formDPTb.lblPerempuan.text = "\(data.a4Perempuan)"
        formDPTb.lblTotal.text = "\(data.aggregates.a4Total)"
        
        formDPK.configure(typeTitle: .pemilihDPK)
        formDPK.lblLaki.text = "\(data.aDpkLaki)"
        formDPK.lblPerempuan.text = "\(data.aDpkPerempuan)"
        formDPK.lblTotal.text = "\(data.aggregates.aDpkTotal)"
        
        formTotalA1A3.configure(typeTitle: .totalPemilihA1A3)
        formTotalA1A3.lblLaki.text = "\(data.aggregates.pemilihLakiTotal)"
        formTotalA1A3.lblPerempuan.text = "\(data.aggregates.pemilihPerempuanTotal)"
        formTotalA1A3.lblTotal.text = "\(data.aggregates.pemilihTotal)"
        
        formHakDPT.configure(typeTitle: .hakDPT)
        formHakDPT.lblLaki.text = "\(data.c7DptLaki)"
        formHakDPT.lblPerempuan.text = "\(data.c7DptPerempuan)"
        formHakDPT.lblTotal.text = "\(data.aggregates.c7DptTotal)"
        
        formHakDPTb.configure(typeTitle: .hakDPTb)
        formHakDPTb.lblLaki.text = "\(data.c7DptbLaki)"
        formHakDPTb.lblPerempuan.text = "\(data.c7DptbPerempuan)"
        formHakDPTb.lblTotal.text = "\(data.aggregates.c7dptbTotal)"
        
        formHakDPK.configure(typeTitle: .hakDPK)
        formHakDPK.lblLaki.text = "\(data.c7DpkLaki)"
        formHakDPK.lblPerempuan.text = "\(data.c7DpkPerempuan)"
        formHakDPK.lblTotal.text = "\(data.aggregates.c7dpkTotal)"
        
        formTotalB1B3.configure(typeTitle: .totalHakB1B3)
        formTotalB1B3.lblLaki.text = "\(data.aggregates.c7LakiHakPilihTotal)"
        formTotalB1B3.lblPerempuan.text = "\(data.aggregates.c7PerempuanHakPilihTotal)"
        formTotalB1B3.lblTotal.text = "\(data.aggregates.c7HakPilihTotal)"
        
        formTotalPemilihDisabilitas.configure(typeTitle: .disabilitasTotal)
        formTotalPemilihDisabilitas.lblLaki.text = "\(data.disabilitasTerdaftarLaki)"
        formTotalPemilihDisabilitas.lblPerempuan.text = "\(data.disabilitasTerdaftarPerempuan)"
        formTotalPemilihDisabilitas.lblTotal.text = "\(data.aggregates.disabilitasTerdaftarTotal)"
        
        formTotalHakDisabilitas.configure(typeTitle: .disabilitasHak)
        formTotalHakDisabilitas.lblLaki.text = "\(data.disabilitiasHakPilihLaki)"
        formTotalHakDisabilitas.lblPerempuan.text = "\(data.disabilitasHakPilihPerempuan)"
        formTotalHakDisabilitas.lblTotal.text = "\(data.aggregates.disabilitasHakPilihTotal)"
    }
    
    func configureDummy() {
        formDPT.configure(typeTitle: .pemilihDPT)
        formDPTb.configure(typeTitle: .pemilihDPTb)
        formDPK.configure(typeTitle: .pemilihDPK)
        formTotalA1A3.configure(typeTitle: .totalPemilihA1A3)
        formHakDPT.configure(typeTitle: .hakDPT)
        formHakDPTb.configure(typeTitle: .hakDPTb)
        formHakDPK.configure(typeTitle: .hakDPK)
        formTotalB1B3.configure(typeTitle: .totalHakB1B3)
        formTotalPemilihDisabilitas.configure(typeTitle: .disabilitasTotal)
        formTotalHakDisabilitas.configure(typeTitle: .disabilitasHak)
    }
    
}
