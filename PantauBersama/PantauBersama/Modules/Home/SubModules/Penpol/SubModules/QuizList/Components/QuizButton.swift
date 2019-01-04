//
//  QuizButton.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common

class QuizButton: Button {
    public func setState(state: QuizModel.QuizStatus) {
        switch state {
        case .notParticipating:
            self.titleLabel?.text = "IKUTI >>"
            self.backgroundColor = #colorLiteral(red: 0.9510135055, green: 0.4663162827, blue: 0.1120762601, alpha: 1)
            break
        case .inProgress:
            self.titleLabel?.text = "LANJUTKAN >>"
            self.backgroundColor = #colorLiteral(red: 0.9195427895, green: 0.1901296675, blue: 0.2161853909, alpha: 1)
            break
        case .finished:
            self.titleLabel?.text = "HASIL >>"
            self.backgroundColor = #colorLiteral(red: 0.01680011675, green: 0.7413030267, blue: 0.6572044492, alpha: 1)
            break
        }
    }
    
    
}
