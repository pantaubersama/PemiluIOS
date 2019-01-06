//
//  ReqClusterController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxCocoa
import RxSwift

class ReqClusterController: UIViewController {
    
    var viewModel: ReqClusterViewModel!
    @IBOutlet weak var iconCluster: UIImageView!
    @IBOutlet weak var buttonAddGambar: UIButton!
    @IBOutlet weak var tfNamaCluster: TextField!
    @IBOutlet weak var btnKategori: Button!
    @IBOutlet weak var tvDeskripsi: UITextView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Request Buat Cluster"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnKategori.rx.tap
            .bind(to: viewModel.input.kategoriI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.kategoriO
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.configure(with: .white)
    }
    
}
