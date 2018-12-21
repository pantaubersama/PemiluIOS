//
//  ProfileController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    
    private var headerView = HeaderProfile()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerReusableCell(LinimasaCell.self)
        tableView.registerReusableCell(LinimasaJanjiCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        let headerView = HeaderProfile()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(handleBack(sender:)))
        let setting = UIBarButtonItem(image: #imageLiteral(resourceName: "outlineSettings24Px"), style: .plain, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = setting
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
    }
    
    @objc private func handleBack(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

extension ProfileController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if headerView.segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as LinimasaCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as LinimasaJanjiCell
            return cell
        }
    }
}
