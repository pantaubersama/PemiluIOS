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
    private let headerView = SummaryPresidenTPSView()
    private let footerView = RekapDetailTPSFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 64.0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.allowsSelection = false
        tableView.registerReusableCell(RekapDetailPhotosCell.self)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        
        title = "TPS"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.summaryPresidenO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                self.headerView.configure(data: response)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.c1SummaryO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                self.footerView.configure(data: response)
            })
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as RekapDetailPhotosCell
        
        return cell
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Lampiran Model C1-PPWP (Presiden)"
        case 1:
            return "Lampiran Model C1-DPR RI"
        case 2:
            return "Lampiran Model C1-DPD"
        case 3:
            return "Lampiran Model C1-DPRD Provinsi"
        case 4:
            return "Lampiran Model C1-DPRD Kabupaten/Kota"
        case 5:
            return "Lampiran Suasana TPS"
        default:
            return nil
        }
    }
}
