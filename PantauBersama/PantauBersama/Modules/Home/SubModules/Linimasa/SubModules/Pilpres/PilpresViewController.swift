//
//  PilpresViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PilpresViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    private var headerView: LinimasaHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(LinimasaCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        headerView = LinimasaHeaderView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
    }
    
}


// Dummy

extension PilpresViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as LinimasaCell
        return cell
    }
}
