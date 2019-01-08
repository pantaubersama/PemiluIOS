//
//  EmptyView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Lottie

final class EmptyView: UIView {
    
    @IBOutlet weak var container: UIView!
    private var lotieView: LOTAnimationView?
    
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
        
        configureLotie()
    }
    
    private func configureLotie() {
        lotieView = LOTAnimationView(name: "empty-status")
        lotieView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        lotieView!.contentMode = .scaleAspectFill
        lotieView!.frame = container.bounds
        container.addSubview(lotieView!)
        lotieView!.play(fromProgress: 0.0,
                        toProgress: 1.0,
                        withCompletion: nil)
    }
    
}
