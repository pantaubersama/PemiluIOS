//
//  CreatePerhitunganController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class CreatePerhitunganController: UIViewController {
    var viewModel: CreatePerhitunganViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Data TPS"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let done = UIBarButtonItem(image: #imageLiteral(resourceName: "icDoneRed"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = done
        // Do any additional setup after loading the view.
    }

}
