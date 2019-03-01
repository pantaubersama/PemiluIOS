//
//  InfoNotifCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 28/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import Networking

typealias InfoNotifiCellConfigured = CellConfigurator<InfoNotifCell, InfoNotifCell.Input>

class InfoNotifCell: UITableViewCell {
    
    @IBOutlet weak var ivImage: CircularUIImageView!
    @IBOutlet weak var content: Label!
    @IBOutlet weak var timestamp: Label!
    private var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
        ivImage.image = #imageLiteral(resourceName: "icDefaultNotif")
    }
    
}

extension InfoNotifCell: IReusableCell {
    
    struct Input {
        let notif: NotificationRecord
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
//        let notifType = item.notif.data.
        content.text = item.notif.notification?.body
        timestamp.text = item.notif.createdAt.id
        
        if let notifType = NotifType(rawValue: item.notif.data.payload?.notifType ?? "") {
            switch notifType {
            case .broadcasts:
                break
            case .janpol:
                break
            case .feed:
                break
            case .profile:
                break
            case .question:
                guard let question = item.notif.data.payload?.question else { return }
                guard let avatar = question.avatar?.thumbnail else {
                    ivImage.image = #imageLiteral(resourceName: "icDummyPerson")
                    return
                }
                ivImage.show(fromURL: avatar)
                break
            case .quiz:
                break
            case .badge:
                guard let badge = item.notif.data.payload?.badge else { return }
                ivImage.show(fromURL: badge.badge.image?.thumbnail ?? "")
                break
            }
        }
        
        disposeBag = bag
    }
    
}
