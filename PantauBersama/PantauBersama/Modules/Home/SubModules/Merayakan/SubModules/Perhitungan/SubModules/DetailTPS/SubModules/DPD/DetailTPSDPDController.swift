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
import Networking

class DetailTPSDPDController: UIViewController {
    var viewModel: DetailTPSDPDViewModel!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnInvalid: TPSButton!
    
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
        
        btnInvalid.rx_suara
            .bind(to: viewModel.input.invalidValueI)
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
            
            cell.btnVote.rx_suara
                .skip(1)
                .map({ CandidatePartyCount(id: item.id, totalVote: $0, indexPath: idx)})
                .bind(to: self.viewModel.input.counterI)
                .disposed(by: cell.disposeBag)
            
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
        
        viewModel.output.candidatePartyCountO
            .do(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                // if id is math then get the latest value
                print("ALL CANDIDATES: \(value)")
                let sum = value.map({ $0.totalVote }).reduce(0, +)
                print("TOTAL ALL: \(sum)")
                self.viewModel.input.lastValueI.onNext(sum)
                
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.suaraSahO
            .do(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                print("SUM TOTAL: \(value)")
                self.footer.tfValidCount.text = "\(value)"
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.suaraInvalidO
            .do(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.footer.tfInvalidCount.text = "\(value)"
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.totalSuaraO
            .do(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.footer.tfCount.text = "\(value)"
            })
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

