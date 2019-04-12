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
    @IBOutlet weak var btnSuaraTidakSah: TPSButton!
    @IBOutlet weak var btnSimpan: Button!
    
    lazy var footer = UIView.nib(withType: DetailTPSDPRFooter.self)
    lazy var header = UIView.nib(withType: DetailTPSDPRHeader.self)
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModelCalculations>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = type.title
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnSuaraTidakSah.rx_suara
            .bind(to: viewModel.input.invalidCountI)
            .disposed(by: disposeBag)
        
        btnSimpan.rx.tap
            .bind(to: viewModel.input.simpanI)
            .disposed(by: disposeBag)
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        tableView.setTableHeaderView(headerView: header)
        tableView.setTableFooterView(footerView: footer)
        tableView.registerReusableCell(TPSInputCell.self)
        tableView.registerReusableCell(TPSInputHeader.self)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModelCalculations>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TPSInputCell
            cell.configureDPD(item: item)
            
            cell.btnVote.rx_suara
                .skip(1)
                .map({ CandidatePartyCount(id: item.id, totalVote: $0, indexPath: indexPath)})
                .bind(to: self.viewModel.input.counterI)
                .disposed(by: cell.disposeBag)
            
            return cell
        })
        
        viewModel.output.itemsSections
            .do(onNext: { [weak self] (sections) in
                guard let `self` = self else { return }
//                self.tableView.reloadData()
                let sumFooter = sections.map({ $0.footerCount }).reduce(0, +)
                self.viewModel.input.suarahSahI.onNext(sumFooter)
                
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.totalSuaraSahO
            .do(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.footer.tfValidCount.text = "\(value)"
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
        
        
        viewModel.output.nameDapilO
            .drive(onNext: { [weak self] (name) in
                guard let `self` = self else { return }
                self.header.configure(name: name)
            })
            .disposed(by: disposeBag)
    
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.invalidO
            .do(onNext: { [weak self] (value) in
                guard let `self` = self else { return }
                self.footer.tfInvalidCount.text = "\(value)"
            })
            .drive()
            .disposed(by: disposeBag)
        
//        viewModel.output.initialValueO
//            .drive()
//            .disposed(by: disposeBag)
//
        viewModel.output.simpanO
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.input.viewWillAppearI.onNext(())
        
        tableView.updateHeaderViewFrame()
    }
}

extension DetailTPSDPRController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 78.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerName = dataSource.sectionModels[section].header
        let number = dataSource.sectionModels[section].headerNumber
        let logo = dataSource.sectionModels[section].headerLogo
        let headerCount = dataSource.sectionModels[section].headerCount
        
        let headerView = tableView.dequeueReusableCell() as TPSInputHeader
        headerView.configureCell(item: TPSInputHeader.Input(name: headerName,
                                                            section: section,
                                                            number: number,
                                                            logo: logo,
                                                            viewModel: self.viewModel,
                                                            headerCount: headerCount))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCount = dataSource.sectionModels[section].footerCount
        let footer = TPSInputFooter()
        
        footer.configure(footerCount: footerCount)
        
        return footer
    }
}
