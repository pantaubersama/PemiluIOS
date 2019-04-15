//
//  C1PemilihDisabilitasView.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import Networking

class C1PemilihDisabilitasView: UIView {

    @IBOutlet weak var txtTerdaftarLaki: TPSTextField!
    @IBOutlet weak var txtTerdaftarPerempuan: TPSTextField!
    @IBOutlet weak var txtTerdaftarTotal: TPSTextField!
    @IBOutlet weak var txtPilihLaki: TPSTextField!
    @IBOutlet weak var txtPilihPerempuan: TPSTextField!
    @IBOutlet weak var txtPilihTotal: TPSTextField!

    private(set) var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
       disposeBag = DisposeBag()
    }
    
    func config(viewModel: C1InputFormViewModel) {
        
        txtTerdaftarLaki.rx.text.orEmpty
            .filter({ !$0.isEmpty })
            .bind(to: viewModel.input.disTerdaftarLakiI)
            .disposed(by: disposeBag)
        
        txtTerdaftarPerempuan.rx.text.orEmpty
            .filter({ !$0.isEmpty })
            .bind(to: viewModel.input.disTerdaftarPerempuanI)
            .disposed(by: disposeBag)
        
        txtPilihLaki.rx.text.orEmpty
            .filter({ !$0.isEmpty })
            .bind(to: viewModel.input.disPilihLakiI)
            .disposed(by: disposeBag)
        
        txtPilihPerempuan.rx.text.orEmpty
            .filter({ !$0.isEmpty })
            .bind(to: viewModel.input.disPilihPerempuanI)
            .disposed(by: disposeBag)
        
        viewModel.output.disTerdaftarTotalO
            .drive(onNext: { (total) in
                self.txtTerdaftarTotal.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.disPilihTotalO
            .drive(onNext: { (total) in
                self.txtPilihTotal.text = total
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func configureInitial(data: C1Response, viewModel: C1InputFormViewModel) {
        txtTerdaftarLaki.text = "\(data.disabilitasTerdaftarLaki)"
        txtTerdaftarPerempuan.text = "\(data.disabilitasTerdaftarPerempuan)"
        txtTerdaftarTotal.text = "\(data.aggregates.disabilitasTerdaftarTotal)"
        txtPilihLaki.text = "\(data.disabilitiasHakPilihLaki)"
        txtPilihPerempuan.text = "\(data.disabilitasHakPilihPerempuan)"
        txtPilihTotal.text = "\(data.aggregates.disabilitasHakPilihTotal)"
        
        viewModel.input.disTerdaftarLakiI.onNext("\(data.disabilitasTerdaftarLaki)")
        viewModel.input.disTerdaftarPerempuanI.onNext("\(data.disabilitasTerdaftarPerempuan)")
        viewModel.input.disPilihLakiI.onNext("\(data.disabilitiasHakPilihLaki)")
        viewModel.input.disPilihPerempuanI.onNext("\(data.disabilitasHakPilihPerempuan)")
    }
    
    func configDataTerkirim(enable: Bool) {
        let groupTxt: [TPSTextField] = [txtTerdaftarLaki, txtTerdaftarPerempuan,
                                        txtTerdaftarTotal, txtPilihLaki,
                                        txtPilihPerempuan, txtPilihTotal]
        groupTxt.forEach { (textField) in
            textField.isEnabled = enable
        }
    }
    
}
