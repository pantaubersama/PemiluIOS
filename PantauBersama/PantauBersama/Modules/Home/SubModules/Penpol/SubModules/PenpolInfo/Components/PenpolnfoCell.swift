//
//  PenpolInfoCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

typealias PenpolInfoViewCellConfigurator = CellConfigurator<PenpolInfoCell, PenpolInfoCell.Input>

class PenpolInfoCell: UITableViewCell, IReusableCell {
    struct Input {
        let viewModel: PenpolInfoCellViewModel
        let infoType: PenpolInfoType
    }
    
    @IBOutlet weak var ivInfoBackground: UIImageView!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var tvTitle: Label!
    @IBOutlet weak var tvDescription: UITextView!
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func configureCell(item: Input) {
        
        switch item.infoType {
        case .Ask:
            ivInfoBackground.image = UIImage(named: "icAskInfoHeader")
            tvTitle.text = "Tanya"
            tvDescription.text = "Apa yang ingin kamu tanyakan kepada Capres & Cawapres Indonesia periode 2019 - 2024 Jokowi - Makruf dan Prabowo - Sandi Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        case .Quiz:
            ivInfoBackground.image = UIImage(named: "icQuizInfoHeader")
            tvTitle.text = "Kuis"
            tvDescription.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        }
        
        tvDescription.textContainer.lineBreakMode = .byWordWrapping
        tvDescription.isScrollEnabled = false
       
    }
}
