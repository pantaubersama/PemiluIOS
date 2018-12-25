//
//  ProfileInfoDummyData.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Networking


enum ProfileHeaderItem: Int {
    case editProfile
    case editPassword
    case editDataLapor
    
    var title: String {
        switch self {
        case .editProfile:
            return "Edit Profile"
        case .editPassword:
            return "Ubah Sandi"
        case .editDataLapor:
            return "Ubah Data Lapor"
        }
    }
}

//final class ProfileInfoDummyData {
//    static func profileInfoData() -> Observable<[SectionOfProfileInfoData]> {
//        let profileInformation = generateProfileInformation()
//        
//        
////        let items = ProfileHeaderItem.items
////            .map { (type) -> SectionOfProfileInfoData in
////                switch type {
////                case .editProfile:
////                    return SectionOfProfileInfoData(
////                        id: "122312",
////                        items:
////                }
////        }
//    }
//    
//    private func generateProfileInformation() -> [ProfileInfoField] {
//        var profileInformation: [ProfileInfoField] = []
//        
//        profileInformation.append(ProfileInfoField(
//            key: ""
//        ))
//    }
//}
