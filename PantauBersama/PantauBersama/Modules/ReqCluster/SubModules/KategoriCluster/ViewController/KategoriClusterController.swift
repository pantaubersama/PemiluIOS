//
//  KategoriClusterController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 05/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class KategoriClusterController: UIViewController {
    
    private let searchBar: UISearchBar = {
       let search = UISearchBar()
        search.searchBarStyle = .minimal
        return search
    }()
    
    var viewModel: KategoriClusterViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cari Kategori"
        navigationItem.titleView = searchBar
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.configure(type: .pantau)
        
    }
    
}
