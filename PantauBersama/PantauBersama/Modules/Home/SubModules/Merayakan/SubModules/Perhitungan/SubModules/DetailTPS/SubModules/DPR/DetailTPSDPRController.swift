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
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        tableView.setTableHeaderView(headerView: header)
        tableView.setTableFooterView(footerView: footer)
        tableView.registerReusableCell(TPSInputCell.self)
        
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
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.tableView.reloadData()
            })
            .drive(tableView.rx.items(dataSource: dataSource))
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
//        viewModel.output.dataO
//            .drive()
//            .disposed(by: disposeBag)
        
//        viewModel.output.updateItemsO
//            .do(onNext: { [unowned self] (_) in
//                self.viewModel.input.viewWillAppearI.onNext(())
//            })
//            .drive()
//            .disposed(by: disposeBag)
        
//        viewModel.output.bufferPartyO
//            .do(onNext: { [weak self] (party) in
//                guard let `self` = self else { return }
//                self.viewModel.input.counterPartyI.onNext(party)
//            })
//            .drive()
//            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.input.viewWillAppearI.onNext(())
        tableView.updateHeaderViewFrame()
    }
}

extension DetailTPSDPRController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerName = dataSource.sectionModels[section].header
        let number = dataSource.sectionModels[section].headerNumber
        let logo = dataSource.sectionModels[section].headerLogo
        let headerView = TPSInputHeader()
        headerView.configure(header: headerName, number: number, logo: logo, viewModel: self.viewModel, section: section)
        
        
        headerView.btnCounter
            .rx_suara
            .map({ PartyCount(section: section, number: number, value: $0) })
            .bind(to: self.viewModel.input.counterPartyI)
            .disposed(by: headerView.disposeBag)
        
//        headerView.btnCounter
//            .rx_suara
//            .map({ PartyCount(section: section, number: number, value: $0) })
//            .subscribe(onNext: { [weak self] (party) in
//                guard let `self` = self else { return }
//                self.viewModel.input.bufferPartyI.onNext(party)
//            })
//            .disposed(by: self.disposeBag)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = TPSInputFooter()
        return footer
    }
}
