//
//  QuizResultController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common

class QuizResultController: UIViewController {
    
    @IBOutlet weak var btnBack: ImageButton!
    @IBOutlet weak var lbResult: Label!
    @IBOutlet weak var lbPercent: Label!
    @IBOutlet weak var lbPaslon: Label!
    @IBOutlet weak var btnShare: Button!
    @IBOutlet weak var btnAnswerKey: Button!
    @IBOutlet weak var ivPaslon: UIImageView!
    
    var viewModel: QuizResultViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
