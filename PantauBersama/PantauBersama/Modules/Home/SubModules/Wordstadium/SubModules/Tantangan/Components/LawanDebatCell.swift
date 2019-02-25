//
//  LawanDebatCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import LTHRadioButton

class LawanDebatCell: UITableViewCell {
    
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var lineStatus: UIView!
    @IBOutlet weak var btnHint: UIButton!
    @IBOutlet weak var containerRadionSymbolic: UIView!
    @IBOutlet weak var containerRadioTwitter: UIView!
    
    @IBOutlet weak var btnSymbolic: UIButton!
    @IBOutlet weak var ivSymboliic: CircularUIImageView!
    @IBOutlet weak var ivStatusSymbolic: UIImageView!
    @IBOutlet weak var lblStatusSymbolic: UILabel!
    
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var ivTwitter: CircularUIImageView!
    @IBOutlet weak var ivStatusTwitter: UIImageView!
    @IBOutlet weak var lblStatusTwitter: UILabel!
    
    lazy var radioButton: LTHRadioButton = {
        let rb = LTHRadioButton(selectedColor: Color.primary_red)
        rb.contentMode = .center
        rb.translatesAutoresizingMaskIntoConstraints = false
        
        return rb
    }()
    
    lazy var radioButtonTwitter: LTHRadioButton = {
        let rb = LTHRadioButton(selectedColor: Color.primary_red)
        rb.contentMode = .center
        rb.translatesAutoresizingMaskIntoConstraints = false
        
        return rb
    }()
    
    private var disposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerRadionSymbolic.addSubview(radioButton)
        containerRadioTwitter.addSubview(radioButtonTwitter)
        
        NSLayoutConstraint.activate([
            radioButton.centerYAnchor.constraint(equalTo: containerRadionSymbolic.centerYAnchor),
            radioButton.centerXAnchor.constraint(equalTo: containerRadionSymbolic.centerXAnchor),
            radioButton.heightAnchor.constraint(equalToConstant: radioButton.frame.height),
            radioButton.widthAnchor.constraint(equalToConstant: radioButton.frame.width),
            
            radioButtonTwitter.centerYAnchor.constraint(equalTo: containerRadioTwitter.centerYAnchor),
            radioButtonTwitter.centerXAnchor.constraint(equalTo: containerRadioTwitter.centerXAnchor),
            radioButtonTwitter.heightAnchor.constraint(equalToConstant: radioButtonTwitter.frame.height),
            radioButtonTwitter.widthAnchor.constraint(equalToConstant: radioButtonTwitter.frame.width)
            ]
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


extension LawanDebatCell: IReusableCell {
    
    struct Input {
        let viewModel: TantanganChallengeViewModel
        let status: Bool
    }
    
    func configure(item: Input) {
        let bag = DisposeBag()
        
        btnSymbolic.rx.tap
            .do(onNext: { [weak self] (_) in
                self?.radioButton.select()
                self?.radioButtonTwitter.deselect()
            })
            .bind(to: item.viewModel.input.symbolicButtonI)
            .disposed(by: bag)
        
        btnHint.rx.tap
            .bind(to: item.viewModel.input.hintDebatI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
}
