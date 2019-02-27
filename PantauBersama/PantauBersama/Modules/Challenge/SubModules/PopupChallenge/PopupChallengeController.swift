//
//  PopupChallengeController2.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 27/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class PopupChallengeController: UIViewController {
    @IBOutlet weak var stackComment: UIStackView!
    @IBOutlet weak var btnBack: Button!
    @IBOutlet weak var btnConfirm: Button!
    @IBOutlet weak var lblInfo: Label!
    @IBOutlet weak var tvReason: UITextView!
    
    var viewModel: PopupChallengeViewModel!
    var type: PopupChallengeType = .default

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
