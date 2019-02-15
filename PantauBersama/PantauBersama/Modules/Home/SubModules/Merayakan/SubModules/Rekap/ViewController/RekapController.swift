//
//  RekapController.swift
//  PantauBersama
//
//  Created by asharijuang on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class RekapController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navbar: Navbar!
    private var headerView: BannerHeaderView!
    private var emptyView = EmptyView()
    private var viewModel: RekapViewModel!
    
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: RekapViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}
