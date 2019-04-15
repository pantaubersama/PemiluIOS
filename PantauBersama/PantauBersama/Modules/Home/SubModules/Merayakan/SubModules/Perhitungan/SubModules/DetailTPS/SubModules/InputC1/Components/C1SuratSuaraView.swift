//
//  C1SuratSuaraView.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import Networking

class C1SuratSuaraView: UIView {
    @IBOutlet weak var txtSuratDikembalikan: TPSTextField!
    @IBOutlet weak var txtSuratTidakDigunakan: TPSTextField!
    @IBOutlet weak var txtSuratDigunakan: TPSTextField!
    @IBOutlet weak var txtSuratDiterima: TPSTextField!
    
    private(set) var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        disposeBag = DisposeBag()
    }
    
    func config(viewModel: C1InputFormViewModel) {
        
        txtSuratDikembalikan.rx.text.orEmpty
            .filter({ !$0.isEmpty })
            .bind(to: viewModel.input.suratDikembalikanI)
            .disposed(by: disposeBag)
        
        txtSuratTidakDigunakan.rx.text.orEmpty
            .filter({ !$0.isEmpty })
            .bind(to: viewModel.input.suratTidakDigunakanI)
            .disposed(by: disposeBag)
        
        txtSuratDigunakan.rx.text.orEmpty
            .filter({ !$0.isEmpty })
            .bind(to: viewModel.input.suratDigunakanI)
            .disposed(by: disposeBag)
        

        
        viewModel.output.suratDiterimaO
            .drive(onNext: { (total) in
                self.txtSuratDiterima.text = total
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func configureViewModel(data: C1Response, viewModel: C1InputFormViewModel) {
        txtSuratDigunakan.text = "\(data.suratDigunakan)"
        txtSuratDikembalikan.text = "\(data.suratDikembalikan)"
        txtSuratTidakDigunakan.text = "\(data.suratTidakDigunakan)"
        txtSuratDiterima.text = "\(data.aggregates.totalSuara)"
        
        viewModel.input.suratDigunakanI.onNext("\(data.suratDigunakan)")
        viewModel.input.suratDikembalikanI.onNext("\(data.suratDikembalikan)")
        viewModel.input.suratTidakDigunakanI.onNext("\(data.suratTidakDigunakan)")
    }
    
    func configure(data: C1Response) {
        txtSuratDigunakan.text = "\(data.suratDigunakan)"
        txtSuratDikembalikan.text = "\(data.suratDikembalikan)"
        txtSuratTidakDigunakan.text = "\(data.suratTidakDigunakan)"
        txtSuratDiterima.text = "\(data.aggregates.totalSuara)"
    }
    
    func configureDummy() {
        txtSuratDigunakan.text = "0"
        txtSuratDikembalikan.text = "0"
        txtSuratTidakDigunakan.text = "0"
        txtSuratDiterima.text = "0"
    }
    
      func configDataTerkirim(enable: Bool) {
        let groupTextField: [TPSTextField] = [txtSuratDikembalikan,
                                              txtSuratTidakDigunakan,
                                              txtSuratDigunakan,
                                              txtSuratDiterima]
        groupTextField.forEach { (textField) in
            textField.isEnabled = enable
        }
        
     }

}
