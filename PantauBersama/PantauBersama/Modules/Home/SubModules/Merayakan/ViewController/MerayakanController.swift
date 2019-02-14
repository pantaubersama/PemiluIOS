//
//  MerayakanController.swift
//  PantauBersama
//
//  Created by asharijuang on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class MerayakanController: UIViewController {

    @IBOutlet weak var segmentedControl: SegementedControl!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var navbar: Navbar!
    var viewModel: MerayakanViewModel!
    
    lazy var rekapViewModel = RekapViewModel(navigator: viewModel.navigator, showTableHeader: true)
    private lazy var rekapController = RekapController(viewModel: rekapViewModel)

    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = .minimal
        search.sizeToFit()
        return search
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navbar.backgroundColor = Color.primary_red

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
//        viewModel.input.viewWillAppearTrigger.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }

}
