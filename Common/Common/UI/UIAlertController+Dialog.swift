//
//  UIAlert+Dialog.swift
//  Common
//
//  Created by Rahardyan Bisma on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import UIKit

public enum AlertDuration {
    case short
    case medium
    case long
}

extension UIAlertController {
    public class func showDismissableAlert(withTitle title: String, andMessage message: String) {
        let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(okButton)
        alert.show()
    }
    
    public class func showAlert(withTitle title: String, andMessage message: String, withinDuration duration: AlertDuration = .short) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var displayedDuration: DispatchTime = .now()
        switch duration {
        case .long:
            displayedDuration = .now() + 3
        case .medium:
            displayedDuration = .now() + 2
        case .short:
            displayedDuration = .now() + 1
        }
        
        alert.show()
        DispatchQueue.main.asyncAfter(deadline: displayedDuration) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
