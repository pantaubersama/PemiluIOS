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
    
    var isSanbox: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Data TPS"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let done = UIBarButtonItem(image: #imageLiteral(resourceName: "icDoneRed"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = done
        navigationController?.navigationBar.configure(with: .white)
        
        noTpsTF.rx.text.orEmpty
            .bind(to: viewModel.input.tpsNoI)
            .disposed(by: disposeBag)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        done.rx.tap
            .bind(to: viewModel.input.detailTPSI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.createO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.formattedAddress
            .asObservable()
            .bind(to: addressLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.getProvinces()
        
        viewModel.updateLocation()
        
        viewModel.output.enableO
            .do(onNext: { (value) in
                done.tintColor = value ? Color.primary_red : Color.grey_three
            })
            .drive(done.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        if viewModel.isEdit == true && isSanbox == false {
            let groupTextField: [TextField] = [provinsiTF,
                                               kabupatenTF,
                                               kecamatanTF,
                                               desaTF]
            groupTextField.forEach { (tf) in
                tf.isEnabled = false
            }
            viewModel.output.initialDataO
                .do(onNext: { [weak self] (realCount) in
                    guard let `self` = self else { return }
                    if let realCount = realCount {
                        self.viewModel.input.provinceI.onNext("\(realCount.provinceCode)")
                        self.viewModel.input.regenciesI.onNext("\(realCount.regencyCode)")
                        self.viewModel.input.districtI.onNext("\(realCount.districtCode)")
                        self.viewModel.input.villageI.onNext("\(realCount.villageCode)")
                        self.provinsiTF.text = realCount.province.name
                        self.kabupatenTF.text = realCount.regency.name
                        self.kecamatanTF.text = realCount.district.name
                        self.desaTF.text = realCount.village.name
                        self.noTpsTF.text = "\(realCount.tps)"
                        self.viewModel.input.tpsNoI.onNext("\(realCount.tps)")
                    }
                })
                .drive()
                .disposed(by: disposeBag)
        } else {
            let groupTextField: [TextField] = [provinsiTF,
                                               kabupatenTF,
                                               kecamatanTF,
                                               desaTF]
            groupTextField.forEach { (tf) in
                tf.isEnabled = true
            }
            
            viewModel.output.createSanboxO
                .drive()
                .disposed(by: disposeBag)
            
        }
        
    }
}

extension CreatePerhitunganController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == provinsiTF {
            let dialog = SelectionDialog(title: "Provinsi", closeButtonTitle: "Tutup")
            viewModel.provinces.forEach({ [weak self] (province) in
                let handler = {
                    self?.viewModel.selectProvince(province)
                    self?.provinsiTF.text = province.name
                    // save local if sandbox
                    if self?.isSanbox == true {
                        UserDefaults.Account.reset(forKey: .nameProvince)
                        UserDefaults.Account.set(province.name, forKey: .nameProvince)
                    }
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
                    self?.viewModel.selectRegency(reg)
                    self?.kabupatenTF.text = reg.name
                    if self?.isSanbox == true {
                        UserDefaults.Account.reset(forKey: .nameRegency)
                        UserDefaults.Account.set(reg.name, forKey: .nameRegency)
                    }
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
                    self?.viewModel.selectDistrict(district)
                    self?.kecamatanTF.text = district.name
                    if self?.isSanbox == true {
                        UserDefaults.Account.reset(forKey: .nameDistrict)
                        UserDefaults.Account.set(district.name, forKey: .nameDistrict)
                    }
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
                    self?.viewModel.selectVillage(village)
                    self?.desaTF.text = village.name
                    if self?.isSanbox == true {
                        UserDefaults.Account.reset(forKey: .nameVillages)
                        UserDefaults.Account.set(village.name, forKey: .nameVillages)
                    }
                    dialog.close()
                }
                dialog.addItem(item: village.name, didTapHandler: handler)
            })
            dialog.show()
            return false
        } else if textField == noTpsTF {
//            let dialog = SelectionDialog(title: "Kelurahan/Desa", closeButtonTitle: "Tutup")
//            viewModel.villages.forEach({ [weak self] (village) in
//                let handler = {
//                    self?.viewModel.selectVillage(village)
//                    self?.desaTF.text = village.name
//                    dialog.close()
//                }
//                dialog.addItem(item: village.name, didTapHandler: handler)
//            })
//            dialog.show()
            
//            guard let noTps = Int(self.noTpsTF.text ?? "") else {return false}
//            self.viewModel.selectTps(noTps)
            return false
        }
        return true
    }
}
