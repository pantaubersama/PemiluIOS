//
//  CreatePerhitunganController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class CreatePerhitunganController: UIViewController {
    var viewModel: CreatePerhitunganViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private var noTpsTF: TextField!
    @IBOutlet private var provinsiTF: TextField!
    @IBOutlet private var kabupatenTF: TextField!
    @IBOutlet private var kecamatanTF: TextField!
    @IBOutlet private var desaTF: TextField!
    
    @IBOutlet private var addressLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Data TPS"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let done = UIBarButtonItem(image: #imageLiteral(resourceName: "icDoneRed"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = done
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        done.rx.tap
            .bind(to: viewModel.input.detailTPSI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.detailTPSO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.formattedAddress
            .asObservable()
            .bind(to: addressLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.getProvinces()
        
        viewModel.updateLocation()
    }
}

extension CreatePerhitunganController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == provinsiTF {
            let dialog = SelectionDialog(title: "Provinsi", closeButtonTitle: "Tutup")
            viewModel.provinces.forEach({ [weak self] (province) in
                let handler = {
                    self?.viewModel.selectedProvince = province
                    self?.provinsiTF.text = province.name
                    dialog.close()
                }
                dialog.addItem(item: province.name, didTapHandler: handler)
            })
            dialog.show()
            return false
            
        } else if textField == kabupatenTF {
            let dialog = SelectionDialog(title: "Kabupaten/Kota", closeButtonTitle: "Tutup")
            viewModel.regencies.forEach({ [weak self] (reg) in
                let handler = {
                    self?.viewModel.selectedRegency = reg
                    self?.kabupatenTF.text = reg.name
                    dialog.close()
                }
                dialog.addItem(item: reg.name, didTapHandler: handler)
            })
            dialog.show()
            return false
            
        } else if textField == kecamatanTF {
            let dialog = SelectionDialog(title: "Kecamatan", closeButtonTitle: "Tutup")
            viewModel.districts.forEach({ [weak self] (district) in
                let handler = {
                    self?.viewModel.selectedDistrict = district
                    self?.kecamatanTF.text = district.name
                    dialog.close()
                }
                dialog.addItem(item: district.name, didTapHandler: handler)
            })
            dialog.show()
            return false
            
        } else if textField == desaTF {
            let dialog = SelectionDialog(title: "Kelurahan/Desa", closeButtonTitle: "Tutup")
            viewModel.villages.forEach({ [weak self] (village) in
                let handler = {
                    self?.viewModel.selectedVillage = village
                    self?.desaTF.text = village.name
                    dialog.close()
                }
                dialog.addItem(item: village.name, didTapHandler: handler)
            })
            dialog.show()
            return false
        }
        return true
    }
}
