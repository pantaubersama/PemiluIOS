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
import URLEmbeddedView

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
                    OGDataProvider.shared.fetchOGData(urlString: linkString) { [unowned self] (data, error) in
                        if let _ = error {
                            return
                        }
                        DispatchQueue.main.async(execute: {
                            self.linkPreview.lblLink.text = data.sourceUrl?.absoluteString
                            self.linkPreview.lblContent.text = data.siteName
                            self.linkPreview.lblDescContent.text = data.pageDescription
                            if let avatar = data.imageUrl?.absoluteString {
                                self.linkPreview.ivAvatarLink.show(fromURL: avatar)
                            }
                        })
                    }
                }
            } else {
                OGImageProvider.shared.clearMemoryCache()
                OGImageProvider.shared.clearAllCache()
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
                    OGDataProvider.shared.fetchOGData(urlString: linkString) { [unowned self] (data, error) in
                        if let _ = error {
                            return
                        }
                        DispatchQueue.main.async(execute: {
                            self.linkPreview.lblLink.text = data.sourceUrl?.absoluteString
                            self.linkPreview.lblContent.text = data.siteName
                            self.linkPreview.lblDescContent.text = data.pageDescription
                            if let avatar = data.imageUrl?.absoluteString {
                                self.linkPreview.ivAvatarLink.show(fromURL: avatar)
                            }
                        })
                    }
                }
            }
        }
    }
}
