//
//  BuatProfileViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

final class BuatProfileViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    private let avatarS = PublishSubject<UIImage?>()
    private let fullNameS = PublishSubject<String?>()
    private let usernameS = PublishSubject<String?>()
    private let descS = PublishSubject<String?>()
    private let locationS = PublishSubject<String?>()
    private let educationS = PublishSubject<String?>()
    private let occupationS = PublishSubject<String?>()
    private var navigator: BuatProfileCoordinator
    
    init(navigator: BuatProfileCoordinator) {
        self.navigator = navigator
        
        
        input = Input()
        
        output = Output()
        
    }
    
}
