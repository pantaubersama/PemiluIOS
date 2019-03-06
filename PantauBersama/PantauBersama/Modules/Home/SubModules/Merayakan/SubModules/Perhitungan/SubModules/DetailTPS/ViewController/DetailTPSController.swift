//
//  DetailTPSController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 26/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

struct ElectionType {
    let tag: Int
    let imgFirstOption: UIImage?
    let imgSecOption: UIImage?
    let title: String
}

class DetailTPSController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAction: Button!
    
    var viewModel: DetailTPSViewModel!
    private let disposeBag = DisposeBag()
    
    fileprivate var elections: [ElectionType] = [
        ElectionType(
            tag: 0,
            imgFirstOption: UIImage(named: "presidenmdpi"),
            imgSecOption: UIImage(named: "c1Presiden"),
            title: "PRESIDEN"
        ),
        ElectionType(
            tag: 1,
            imgFirstOption: UIImage(named: "dpRmdpi"),
            imgSecOption: UIImage(named: "c1DPR"),
            title: "DPR RI"
        ),
        ElectionType(
            tag: 2,
            imgFirstOption: UIImage(named: "dpDmdpi"),
            imgSecOption: UIImage(named: "c1DPD"),
            title: "DPD"
        ),
        ElectionType(
            tag: 3,
            imgFirstOption: UIImage(named: "dprdProvinsimdpi"),
            imgSecOption: UIImage(named: "c1DPRDProv"),
            title: "DPRD PROVINSI"
        ),
        ElectionType(
            tag: 4,
            imgFirstOption: UIImage(named: "dprdKabmdpi"),
            imgSecOption: UIImage(named: "c1DPRDKab"),
            title: "DPRD KABUPATEN/KOTA"
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.registerReusableCell(ElectionTypeCell.self)
        tableView.registerReusableCell(DetailTPSHeader.self)
        tableView.registerReusableCell(DetailTPSFooter.self)

        title = "Perhitungan"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnAction.rx.tap
            .bind(to: viewModel.input.sendDataActionI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.sendDataActionO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.detailPresidenO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.detailDPRO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.detailDPRKotaO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.detailDPRProvO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.detailDPDO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.c1UploadO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.c1PresidenO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.c1DPRO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.c1DPDO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.c1DPRDProvO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.c1DPRDKotaO
            .drive()
            .disposed(by: disposeBag)
    }
}

extension DetailTPSController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elections.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell() as DetailTPSHeader
            return cell
            
        } else if indexPath.row == (elections.count + 1) {
            let cell = tableView.dequeueReusableCell() as DetailTPSFooter
            cell.configureCell(item: DetailTPSFooter.Input(viewModel: self.viewModel))
            return cell
        }
        
        let cell = tableView.dequeueReusableCell() as ElectionTypeCell
        let input = ElectionTypeCell.Input(data: elections[indexPath.row - 1], viewModel: self.viewModel)
        cell.configureCell(item: input)
        return cell
    }
}
