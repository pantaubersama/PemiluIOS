//
//  PopupChallengeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class PopoupChallengeController: UIViewController {
    
    @IBOutlet weak var stackComment: UIStackView!
    @IBOutlet weak var btnBack: Button!
    @IBOutlet weak var btnConfirm: Button!
    @IBOutlet weak var lblInfo: Label!
    @IBOutlet weak var tvReason: UITextView!
    
    var viewModel: PopupChallengeViewModel!
    var type: PopupChallengeType = .default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

extension PopoupChallengeController {
    
    private func config(type: PopupChallengeType) {
        switch type {
        case .refuse:
            self.btnConfirm.backgroundColor = #colorLiteral(red: 0.9470950961, green: 0.2843497396, blue: 0.275824368, alpha: 1)
            self.btnConfirm.setTitle("YA, TOLAK", for: UIControlState())
        default:
            break
        }
    }
    
}
