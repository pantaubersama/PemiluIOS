//
//  DetailTPSDPRController.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

enum TPSDPRType {
    case DPRRI
    case DPRDProv
    case DPRDKota
    
    var title: String {
        switch self {
        case .DPRDKota:
            return "DPRD KAB/KOTA"
        case .DPRDProv:
            return "DPRD PROVINSI"
        case .DPRRI:
            return "DPR RI"
        }
    }
}

class DetailTPSDPRController: UIViewController {
    var viewModel: DetailTPSDPRViewModel!
    var type: TPSDPRType = .DPRRI
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var footer = UIView.nib(withType: DetailTPSDPRFooter.self)
    lazy var header = UIView.nib(withType: DetailTPSDPRHeader.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = type.title
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        tableView.setTableHeaderView(headerView: header)
        tableView.setTableFooterView(footerView: footer)
        tableView.registerReusableCell(TPSInputCell.self)
        tableView.registerReusableHeaderCell(TPSInputFooter.self)
        tableView.registerReusableHeaderCell(TPSInputHeader.self)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.updateHeaderViewFrame()
    }
}

extension DetailTPSDPRController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooter() as TPSInputHeader
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooter() as TPSInputFooter
        return footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as TPSInputCell
        return cell
    }
}
