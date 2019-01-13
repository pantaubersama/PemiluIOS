//
//  SosmedController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Common

class SosmedController: UITableViewController {
    
    var viewModel: SosmedViewModel!
    private let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfSettingData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Connect"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let done = UIBarButtonItem(image: #imageLiteral(resourceName: "baselineCheck24Px"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = done
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 44.0
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(SettingCell.self)
        tableView.tableFooterView = UIView()
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        done.rx.tap
            .bind(to: viewModel.input.doneI)
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfSettingData>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as SettingCell
            cell.configureCell(item: SettingCell.Input(data: item))
            return cell
        })
        
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemsO
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.doneO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.itemsSelectedO
            .drive()
            .disposed(by: disposeBag)
    }
    
}

extension SosmedController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionCell()
        view.button.isHidden = true
        view.label.text = dataSource.sectionModels[section].header
        return view
    }
}
