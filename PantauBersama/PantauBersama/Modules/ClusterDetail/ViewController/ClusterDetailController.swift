//
//  ClusterDetailController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

class ClusterDetailController: UIViewController {
    @IBOutlet weak var ivCluster: UIImageView!
    @IBOutlet weak var lbClusterName: Label!
    @IBOutlet weak var lbClusterCategory: Label!
    @IBOutlet weak var lbClusterMembersCount: Label!
    @IBOutlet weak var lbClusterDescription: Label!
    @IBOutlet weak var btnBack: ImageButton!
    
    var viewModel: ClusterDetailViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbClusterDescription.text = "Deskripsi merupakan cluster is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Deskripsi merupakan cluster is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."

        btnBack.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.cluster
            .drive(onNext: { [unowned self]cluster in
                self.ivCluster.show(fromURL: cluster.image?.medium.url ?? "")
                self.lbClusterName.text = cluster.name ?? ""
                self.lbClusterCategory.text = cluster.category?.name ?? ""
                self.lbClusterMembersCount.text = cluster.memberCountString
                self.lbClusterDescription.text = cluster.description ?? ""
            })
            .disposed(by: disposeBag)
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.configure(with: .transparent)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)        
        navigationController?.navigationBar.isHidden = false
    }

}
