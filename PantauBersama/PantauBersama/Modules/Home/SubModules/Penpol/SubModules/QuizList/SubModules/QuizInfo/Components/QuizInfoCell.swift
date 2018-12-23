//
//  QuizInfoCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

typealias QuizInfoViewCellConfigurator = CellConfigurator<QuizInfoCell, QuizInfoCell.Input>

class QuizInfoCell: UITableViewCell, IReusableCell {
    struct Input {
        let viewModel: QuizInfoCellViewModel
    }
    
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var tvDescription: UITextView!
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tvDescription.textContainer.lineBreakMode = .byWordWrapping
        tvDescription.isScrollEnabled = false
        tvDescription.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func configureCell(item: Input) {
        
    }
}
