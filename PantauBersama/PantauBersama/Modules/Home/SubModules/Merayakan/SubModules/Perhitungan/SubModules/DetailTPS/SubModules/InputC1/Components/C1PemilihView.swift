//
//  C1DataPemilihView.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class C1PemilihView: UIView {

    @IBOutlet weak var txtA3Laki: TPSTextField!
    @IBOutlet weak var txtA3Perempuan: TPSTextField!
    @IBOutlet weak var txtA3Total: TPSTextField!
    @IBOutlet weak var txtA4Laki: TPSTextField!
    @IBOutlet weak var txtA4Perempuan: TPSTextField!
    @IBOutlet weak var txtA4Total: TPSTextField!
    @IBOutlet weak var txtADPKLaki: TPSTextField!
    @IBOutlet weak var txtADPKPerempuan: TPSTextField!
    @IBOutlet weak var txtADPKTotal: TPSTextField!
    @IBOutlet weak var txtTotalLakiA3: TPSTextField!
    @IBOutlet weak var txtTotalPerempuanA3: TPSTextField!
    @IBOutlet weak var txtTotalAllA3: TPSTextField!
    

    @IBOutlet weak var txtC7DPTLaki: TPSTextField!
    @IBOutlet weak var txtC7DPTPerempuan: TPSTextField!
    @IBOutlet weak var txtC7DPTTotal: TPSTextField!
    @IBOutlet weak var txtC7DPTBLaki: TPSTextField!
    @IBOutlet weak var txtC7DPTBPerempuan: TPSTextField!
    @IBOutlet weak var txtC7DPTBTotal: TPSTextField!
    @IBOutlet weak var txtC7DPKLaki: TPSTextField!
    @IBOutlet weak var txtC7DPKPerempuan: TPSTextField!
    @IBOutlet weak var txtC7DPKTotal: TPSTextField!
    @IBOutlet weak var txtTotalLakiC7: TPSTextField!
    @IBOutlet weak var txtTotalPerempuanC7: TPSTextField!
    @IBOutlet weak var txtTotalAllC7: TPSTextField!
    
    
    private(set) var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        disposeBag = DisposeBag()
    }
    
    func config(viewModel: C1InputFormViewModel) {
        
        txtA3Laki.rx.text.orEmpty
            .bind(to: viewModel.input.A3LakiI)
            .disposed(by: disposeBag)

        txtA3Perempuan.rx.text.orEmpty
            .bind(to: viewModel.input.A3PerempuanI)
            .disposed(by: disposeBag)

        txtA4Laki.rx.text.orEmpty
            .bind(to: viewModel.input.A4LakiI)
            .disposed(by: disposeBag)
        
        txtA4Perempuan.rx.text.orEmpty
            .bind(to: viewModel.input.A4PerempuanI)
            .disposed(by: disposeBag)
        
        txtADPKLaki.rx.text.orEmpty
            .bind(to: viewModel.input.ADPKLakiI)
            .disposed(by: disposeBag)
        
        txtADPKPerempuan.rx.text.orEmpty
            .bind(to: viewModel.input.ADPKPerempuanI)
            .disposed(by: disposeBag)

        txtC7DPTLaki.rx.text.orEmpty
            .bind(to: viewModel.input.C7DPTLakiI)
            .disposed(by: disposeBag)
        
        txtC7DPTPerempuan.rx.text.orEmpty
            .bind(to: viewModel.input.C7DPTPerempuanI)
            .disposed(by: disposeBag)
        
        txtC7DPTBLaki.rx.text.orEmpty
            .bind(to: viewModel.input.C7DPTBLakiI)
            .disposed(by: disposeBag)
        
        txtC7DPTBPerempuan.rx.text.orEmpty
            .bind(to: viewModel.input.C7DPTBPerempuanI)
            .disposed(by: disposeBag)
        
        txtC7DPKLaki.rx.text.orEmpty
            .bind(to: viewModel.input.C7DPKLakiI)
            .disposed(by: disposeBag)
        
        txtC7DPKPerempuan.rx.text.orEmpty
            .bind(to: viewModel.input.C7DPKPerempuanI)
            .disposed(by: disposeBag)


        viewModel.output.A3TotalO
            .drive(onNext: { (total) in
                self.txtA3Total.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.A4TotalO
            .drive(onNext: { (total) in
                self.txtA4Total.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.ADPKTotalO
            .drive(onNext: { (total) in
                self.txtADPKTotal.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.TotaLakiA3O
            .drive(onNext: { (total) in
                self.txtTotalLakiA3.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.TotalPerempuanA3O
            .drive(onNext: { (total) in
                self.txtTotalPerempuanA3.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.TotalAllA3O
            .drive(onNext: { (total) in
                self.txtTotalAllA3.text = total
            })
            .disposed(by: self.disposeBag)
        
        
        viewModel.output.C7DPKTotalO
            .drive(onNext: { (total) in
                self.txtC7DPKTotal.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.C7DPTBTotalO
            .drive(onNext: { (total) in
                self.txtC7DPTBTotal.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.C7DPTTotalO
            .drive(onNext: { (total) in
                self.txtC7DPTTotal.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.TotalLakiC7O
            .drive(onNext: { (total) in
                self.txtTotalLakiC7.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.TotalPerempuanC7O
            .drive(onNext: { (total) in
                self.txtTotalPerempuanC7.text = total
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.TotalAllC7O
            .drive(onNext: { (total) in
                self.txtTotalAllC7.text = total
            })
            .disposed(by: self.disposeBag)
        
    }

}
