//
//  DetailTPSDPDController.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DetailTPSDPDController: UIViewController {
    var viewModel: DetailTPSDPDViewModel!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var footer = UIView.nib(withType: DetailTPSDPRFooter.self)
    lazy var header = UIView.nib(withType: DetailTPSDPRHeader.self)
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModelDPD>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "DPD"
        
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
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        /// Setup Datasource
        dataSource = RxTableViewSectionedReloadDataSource<SectionModelDPD>(configureCell: { (ds, table, idx, item) -> UITableViewCell in
            let cell = self.tableView.dequeueReusableCell(indexPath: idx) as TPSInputCell
            cell.configureDPD(item: item)
            return cell
        })
        
        viewModel.output.items
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.tableView.reloadData()
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        header.configure(name: viewModel.nameWilayahRelay.value)
        
//        dataSource.titleForHeaderInSection = { dataSource, indexPath in
//            return dataSource.sectionModels[indexPath].header
//        }
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.updateHeaderViewFrame()
    }
}

extension DetailTPSDPDController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = DetailTPSDPRHeader()
//        let name = dataSource.sectionModels[section].header
//        header.configure(name: name)
//        return header
//    }
}

