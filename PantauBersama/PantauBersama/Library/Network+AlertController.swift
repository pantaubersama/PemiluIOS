//
//  Network+AlertController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 28/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Networking
import RxSwift

extension UIAlertController {
    static func alert(with error: Error) -> UIAlertController? {
        guard let error = error as? NetworkError else { return nil }
        let alert = UIAlertController(title: "", message: error.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        return alert
    }
    
}
