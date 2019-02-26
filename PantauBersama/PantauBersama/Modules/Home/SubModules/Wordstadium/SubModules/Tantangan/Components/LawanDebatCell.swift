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
    @IBOutlet weak var statusBottom: UIImageView!
    @IBOutlet weak var lineStatus: UIView!
    @IBOutlet weak var btnHint: UIButton!
    @IBOutlet weak var containerRadionSymbolic: UIView!
    @IBOutlet weak var containerRadioTwitter: UIView!
    
    @IBOutlet weak var btnSymbolic: UIButton!
    @IBOutlet weak var ivSymboliic: CircularUIImageView!
    @IBOutlet weak var ivStatusSymbolic: UIImageView!
    @IBOutlet weak var lblStatusSymbolic: UILabel!
    @IBOutlet weak var lblFullNameSymbolic: Label!
    @IBOutlet weak var lblUsernameSymbolic: Label!
    
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var ivTwitter: CircularUIImageView!
    @IBOutlet weak var ivStatusTwitter: UIImageView!
    @IBOutlet weak var lblStatusTwitter: UILabel!
    @IBOutlet weak var lblFullnameTwitter: Label!
    @IBOutlet weak var lblUsernameTwitter: Label!
    
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
        let data: SearchUserModel?
    }
    
    func configure(item: Input) {
        let bag = DisposeBag()
        
        lineStatus.backgroundColor = item.status ? #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1) : #colorLiteral(red: 0.7960169315, green: 0.7961130738, blue: 0.7959839106, alpha: 1)
        status.image = item.status ? #imageLiteral(resourceName: "checkDone") : #imageLiteral(resourceName: "checkUnactive")
        statusBottom.image = item.status ? nil : #imageLiteral(resourceName: "checkInactive")
        if item.status == false {
            clearTwitter()
            clearSymbolic()
            self.radioButtonTwitter.deselect()
            self.radioButton.deselect()
            lblStatusSymbolic.isHidden = false
            lblStatusTwitter.isHidden = false
        }
        
        btnSymbolic.rx.tap
            .do(onNext: { [weak self] (_) in
                self?.radioButton.select()
                self?.radioButtonTwitter.deselect()
            })
            .bind(to: item.viewModel.input.symbolicButtonI)
            .disposed(by: bag)
        
        btnTwitter.rx.tap
            .do(onNext: { [weak self] (_) in
                self?.radioButton.deselect()
                self?.radioButtonTwitter.select()
            })
            .bind(to: item.viewModel.input.twitterButtonI)
            .disposed(by: bag)
        
        btnHint.rx.tap
            .bind(to: item.viewModel.input.hintDebatI)
            .disposed(by: bag)
        
        if item.data != nil && self.radioButton.isSelected {
            print("data from symbolic")
            lblStatusSymbolic.isHidden = true
            lblStatusTwitter.isHidden = false
            clearTwitter()
            lblFullNameSymbolic.text = item.data?.fullName
            lblUsernameSymbolic.text = item.data?.screenName
            if let url = item.data?.avatar {
                ivSymboliic.show(fromURL: url)
            } else {
                ivSymboliic.image = #imageLiteral(resourceName: "icDummyPerson")
            }
        } else if item.data != nil && self.radioButtonTwitter.isSelected {
            print("data from twitter")
            lblStatusSymbolic.isHidden = false
            lblStatusTwitter.isHidden = true
            clearSymbolic()
            lblUsernameTwitter.text = item.data?.screenName
            lblFullnameTwitter.text = item.data?.fullName
            if let url = item.data?.avatar {
                ivTwitter.show(fromURL: url)
            } else {
                ivTwitter.image = #imageLiteral(resourceName: "icDummyPerson")
            }
        }
        
        disposeBag = bag
    }
    
    private func clearTwitter() {
        lblFullnameTwitter.text = nil
        lblUsernameTwitter.text = nil
        ivTwitter.image = #imageLiteral(resourceName: "flatTwitterBadge72Px")
    }
    
    private func clearSymbolic() {
        lblUsernameSymbolic.text = nil
        lblFullNameSymbolic.text = nil
        ivSymboliic.image = #imageLiteral(resourceName: "icSymbolic")
    }
    
}
