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
    
    @IBOutlet weak var content: Label!
    @IBOutlet weak var timestamp: Label!
    private var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension InfoNotifCell: IReusableCell {
    
    struct Input {
        let notif: NotificationRecord
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
//        let notifType = item.notif.data.
        
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
                break
            case .quiz:
                break
            case .badge:
                break
            }
        }

        content.text = item.notif.notification?.body
        
        disposeBag = bag
    }
    
}
