//
//  InputC1PresidenController.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 03/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class C1InputFormController: UIViewController {
    @IBOutlet weak var containerView: UIStackView!
    
    lazy var pemilihView = UIView.nib(withType: C1PemilihView.self)
    lazy var pemilihDisabilitasView = UIView.nib(withType: C1PemilihDisabilitasView.self)
    lazy var suratSuaraView = UIView.nib(withType: C1SuratSuaraView.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Model C1 Presiden"

        containerView.addArrangedSubview(pemilihView)
        containerView.addArrangedSubview(pemilihDisabilitasView)
        containerView.addArrangedSubview(suratSuaraView)
    }
}
