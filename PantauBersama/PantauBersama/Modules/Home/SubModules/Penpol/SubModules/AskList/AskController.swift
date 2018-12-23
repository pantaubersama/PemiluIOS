//
//  AskController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AskController: UITableViewController {

    private let disposeBag: DisposeBag = DisposeBag()
    private var viewModel: AskViewModel!
    
    convenience init(viewModel: AskViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(BannerInfoAskCell.self)
        tableView.registerReusableCell(HeaderAskCell.self)
        tableView.registerReusableCell(AskViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        viewModel.output.createSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.infoSelected
            .drive()
            .disposed(by: disposeBag)
    }

}


extension AskController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? 15 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BannerInfoAskCell
            cell.bind(viewModel: viewModel)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as HeaderAskCell
            cell.bind(viewModel: viewModel)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as AskViewCell
            return cell
        }
    }
}
