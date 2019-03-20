//
//  ChallengeDetailView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking
import RxSwift

@IBDesignable
class ChallengeDetailView: UIView {
    
    @IBOutlet weak var lblTag: UIPaddedLabel!
    @IBOutlet weak var linkPreview: LinkPreviewView!
    @IBOutlet weak var lblStatement: UILabel!
    @IBOutlet weak var lawanDebatView: LawanDebatView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSaldo: UILabel!
    @IBOutlet weak var spacingLawanDebat: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    // Configure data with local Model Challenge Model
    func configure(type: Bool, data: ChallengeModel) {
        switch type {
        case true:
            // for direct
            lawanDebatView.isHidden = false
            lawanDebatView.configure(data: data)
            lblSaldo.text = data.limitAt
            lblDate.text = data.dateString
            lblTime.text = data.timeString
            lblTag.text = data.tag
            lblTag.layer.borderColor = #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1)
            lblTag.layer.borderWidth = 1.0
            lblStatement.text = data.statement
            if data.source != "" {
                self.linkPreview.isHidden = false
                self.linkPreview.btnCloseLink.isHidden = true
                // Graph data
                if let linkString = data.source {
                    self.linkPreview.configureLink(url: linkString)
                }
            } else {
                self.linkPreview.ivAvatarLink.af_cancelImageRequest()
                self.linkPreview.ivAvatarLink.image = nil
            }
        case false:
            // for open
            lblSaldo.text = data.limitAt
            lblDate.text = data.dateString
            lblTime.text = data.timeString
            lblTag.text = data.tag
            lblTag.layer.borderColor = #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1)
            lblTag.layer.borderWidth = 1.0
            lblStatement.text = data.statement
            if data.source != "" {
                self.linkPreview.isHidden = false
                self.linkPreview.btnCloseLink.isHidden = true
                // Graph data
                if let linkString = data.source {
                    self.linkPreview.configureLink(url: linkString)
                }
            }
        }
    }
    
    /// Configure Data with Challenge Model
    func configureData(data: Challenge) {
        switch data.type {
        case .directChallenge:
            self.lawanDebatView.isHidden = false
            self.lawanDebatView.configureOpponents(data: data)
        case .openChallenge:
            self.lawanDebatView.isHidden = true
        default:
            break
        }
        self.lblTag.layer.borderColor = #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1)
        self.lblTag.layer.borderWidth = 1.0
        self.lblTag.text = data.topic?.first ?? ""
        self.lblStatement.text = data.statement
        if let time = data.showTimeAt {
            let mTimeStart = time.date(format: Constant.timeFormat) ?? ""
            self.lblTime.text = mTimeStart
            self.lblDate.text = time.date(format: Constant.dateTimeFormat5)
        }
        self.lblTime.text = data.showTimeAt?.time
        self.lblSaldo.text = "\(data.timeLimit ?? 0)"
        /// check source statement nil or not
        if data.source != "" {
            self.linkPreview.isHidden = false
            self.linkPreview.btnCloseLink.isHidden = true
            if let source = data.source {
                self.linkPreview.configureLink(url: source)
            }
        } else {
            self.linkPreview.isHidden = true
        }
    }
}
