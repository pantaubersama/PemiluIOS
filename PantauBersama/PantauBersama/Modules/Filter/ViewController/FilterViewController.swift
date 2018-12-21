//
//  FilterViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Common
import RxDataSources

class FilterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var viewModel: IFilterViewModel!
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfFilterData>!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filter"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let reset = UIBarButtonItem(title: "RESET", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = reset
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.registerReusableCell(ItemRadioCell.self)
        
        // MARK
        // Preparation using datasource from model
        // ...
        dataSource =
            RxTableViewSectionedReloadDataSource<SectionOfFilterData>(configureCell: { (dataSource, tableView, indexPath, item) in
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ItemRadioCell
                cell.configureCell(item: ItemRadioCell.Input(data: item))
                return cell
            })
    }
    
}

// Dummy

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ItemRadioCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Sumber Data"
    }
}
