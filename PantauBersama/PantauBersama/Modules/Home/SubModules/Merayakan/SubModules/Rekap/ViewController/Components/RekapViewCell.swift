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

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var regionView: UIView!
    @IBOutlet weak var tpsView: UIView!
    @IBOutlet weak var regionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tpsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelRegionName: UILabel!
    
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
        self.container.layer.masksToBounds  = true
        self.container.layer.borderWidth    = 1
        self.container.layer.borderColor    = #colorLiteral(red: 0.9293106794, green: 0.929469943, blue: 0.9293007255, alpha: 1)
        self.container.layer.cornerRadius   = 5
        
        self.viewBullet1.layer.cornerRadius = self.viewBullet1.frame.width/2
        self.viewBullet2.layer.cornerRadius = self.viewBullet2.frame.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension RekapViewCell : IReusableCell {
    
    struct Input {
        let data: SimpleSummary
        let type: RekapType
    }
    
    func configureCell(item: Input) {
        labelSuaraTidakSah.text = "\(item.data.percentage?.invalidVote.totalVote ?? 0)"
        labelTotalSuara.text = "\(item.data.percentage?.totalVote ?? 0)"
        let paslon1 = item.data.percentage?.candidates?.filter({ $0.id == 1}).first
        let paslon2 = item.data.percentage?.candidates?.filter({ $0.id == 2}).first
        labelPersentase1.text = "\(paslon1?.percentage ?? 0.0)%"
        labelPersentase2.text = "\(paslon2?.percentage ?? 0.0)%"
        labelRegion.text = item.data.region?.name
        
        switch item.type {
        case .tps:
            self.regionView.isHidden    = true
            self.regionTopConstraint.constant  = -(self.regionView.frame.height)
            self.tpsView.isHidden       = false
        default:
            self.tpsView.isHidden       = true
            self.tpsTopConstraint.constant  = -(self.tpsView.frame.height)
            self.regionView.isHidden    = false
        }
    }
    
    // Setup UI and data
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
