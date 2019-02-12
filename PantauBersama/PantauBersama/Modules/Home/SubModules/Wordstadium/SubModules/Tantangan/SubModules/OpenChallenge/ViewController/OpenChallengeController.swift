//
//  OpenChallengeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import RxDataSources

class OpenChallengeController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnNext: ImageButton!
    private let disposeBag = DisposeBag()
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfTantanganData>!
    
    var viewModel: OpenChallengeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Open challenge"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        tableView.estimatedRowHeight = 77.0
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(TantanganCell.self)
        tableView.registerReusableCell(BidangKajianCell.self)
        tableView.registerReusableCell(PernyataanCell.self)
        tableView.registerReusableCell(DateTimeCell.self)
        tableView.registerReusableCell(SaldoTimeCell.self)
        tableView.tableHeaderView = HeaderTantanganView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfTantanganData>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BidangKajianCell
                cell.configureCell(item: BidangKajianCell.Input(viewModel: self.viewModel))
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as PernyataanCell
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as DateTimeCell
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as SaldoTimeCell
                return cell
            default:
                let cell = UITableViewCell()
                return cell
            }
        })
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    
        viewModel.output.itemsO
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.kajianSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.hintKajianO
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.configure(with: .white)
        
        viewModel.input.kajianI.onNext(false)
        viewModel.input.pernyataanI.onNext(true)
        viewModel.input.dateTimeI.onNext(true)
        viewModel.input.saldoI.onNext(true)
    }
    
}

extension OpenChallengeController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 90.0
        case 1:
            return 219.0
        case 2:
            return 151.0
        case 3:
            return 140.0
        default:
            return 77.0
        }
    }
    
}
