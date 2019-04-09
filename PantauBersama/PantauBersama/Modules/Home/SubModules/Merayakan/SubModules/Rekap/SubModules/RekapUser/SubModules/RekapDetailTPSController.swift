//
//  RekapDetailTPSController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import RxDataSources

class RekapDetailTPSController: UITableViewController {
    
    var viewModel: RekapDetailTPSViewModel!
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModelsTPSSummary>!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rowHeight = 44.0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.registerReusableCell(RekapViewCell.self)
        
        title = "TPS"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModelsTPSSummary>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case .presiden(let data):
                let cell = tableView.dequeueReusableCell() as RekapViewCell
                return cell
            case .lampiran(let data):
                let cell = tableView.dequeueReusableCell() as RekapViewCell
                return cell
            case .c1PemilihDPT(let c1Summary),
                 .c1PemilihDPTb(let c1Summary),
                 .c1PemilihDPK(let c1Summary),
                 .c1TotalPemilihA1A3(let c1Summary),
                 .c1HakDPT(let c1Summary),
                 .c1HakDPTb(let c1Summary),
                 .c1HakDPK(let c1Summary),
                 .c1TotalHakB1B3(let c1Summary),
                 .c1DisabilitasTotal(let c1Summary),
                 .c1DisabilitasHak(let c1Summary),
                 .c1TotalSuaraDPT(let c1Summary),
                 .c1TotalSuraRusak(let c1Summary),
                 .c1TotalSuaraTidakDigunakan(let c1Summary),
                 .c1TotalSuaraDigunakan(let c1Summary):
                let cell = tableView.dequeueReusableCell() as RekapViewCell
                return cell
            }
        })
        
        viewModel.output.itemsO
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
