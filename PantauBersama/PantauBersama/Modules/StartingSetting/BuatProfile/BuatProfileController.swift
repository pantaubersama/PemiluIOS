//
//  BuatProfileController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class BuatProfileController: UIViewController {

    var viewModel: BuatProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buat Profilmu"
        navigationController?.navigationBar.configure(with: .white)
    }
    
}
