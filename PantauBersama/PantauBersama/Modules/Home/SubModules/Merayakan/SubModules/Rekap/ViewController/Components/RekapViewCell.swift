//
//  RekapViewCell.swift
//  PantauBersama
//
//  Created by asharijuang on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

class RekapViewCell: UITableViewCell {

    @IBOutlet weak var regionView: UIView!
    @IBOutlet weak var tpsView: UIView!
    @IBOutlet weak var regionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tpsTopConstraint: NSLayoutConstraint!
    
    
    
    // TPS
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var labelTps: UILabel!
    @IBOutlet weak var labelParticipantName: UILabel!
    
    // Region
    @IBOutlet weak var labelRegion: UILabel!
    
    // Suara
    @IBOutlet weak var viewBullet1: UIView!
    @IBOutlet weak var labelPersentase1: UILabel!
    @IBOutlet weak var labelPersentase2: UILabel!
    @IBOutlet weak var viewBullet2: UIView!
    @IBOutlet weak var labelSuaraTidakSah: UILabel!
    @IBOutlet weak var labelTotalSuara: UILabel!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension RekapViewCell : IReusableCell {
    
    // Setup UI
    func configure(data: String, type: RekapType) {
        switch type {
        case .tps:
//            self.regionTopConstraint.constant =
            self.regionView.isHidden    = true
            self.regionTopConstraint.constant  = -(self.regionView.frame.height)
            self.tpsView.isHidden       = false
        default:
            self.tpsView.isHidden       = true
            self.tpsTopConstraint.constant  = -(self.tpsView.frame.height)
            self.regionView.isHidden    = false
        }
    }
}
