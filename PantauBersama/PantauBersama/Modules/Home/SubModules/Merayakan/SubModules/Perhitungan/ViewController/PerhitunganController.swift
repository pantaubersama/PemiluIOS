//
//  PerhitunganController.swift
//  PantauBersama
//
//  Created by asharijuang on 20/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class PerhitunganController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var emptyView = EmptyView()
    var viewModel: PerhitunganViewModel!
    private var headerView: BannerHeaderView!
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: PerhitunganViewModel) {
        self.init()
        self.viewModel  = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        
        tableView.registerReusableCell(TPSViewCell.self)
        
        // table view header
        self.headerView                 = BannerHeaderView()
        self.tableView.tableHeaderView  = headerView
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension PerhitunganController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

extension PerhitunganController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as TPSViewCell
        // cell.configure(data: "", type: self.pageType)
        return cell
    }
    
    
}
