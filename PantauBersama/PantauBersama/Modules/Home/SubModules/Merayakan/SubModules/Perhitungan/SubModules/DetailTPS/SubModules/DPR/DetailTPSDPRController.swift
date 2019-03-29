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
import RxDataSources
import Networking

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
    
    private var animatedDataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, CandidateResponse>>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = type.title
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        tableView.setTableHeaderView(headerView: header)
        tableView.setTableFooterView(footerView: footer)
        tableView.registerReusableCell(TPSInputCell.self)
        tableView.registerReusableHeaderCell(TPSInputFooter.self)
        tableView.registerReusableHeaderCell(TPSInputHeader.self)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        animatedDataSource =
            RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, CandidateResponse>>(configureCell: { (dataSource, tableView, indexPath, response) in
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TPSInputCell
                return cell
            })
        
        viewModel.output.data
            .map({ data in
                [AnimatableSectionModel(model: "Section", items: data)]
            })
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.updateHeaderViewFrame()
    }
}

extension DetailTPSDPRController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooter() as TPSInputHeader
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooter() as TPSInputFooter
        return footer
    }
}
