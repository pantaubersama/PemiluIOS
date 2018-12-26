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

final class ProfileInfoDummyData {
    static func profileInfoData() -> Observable<[SectionOfProfileInfoData]> {
        let profileInformation = generateProfileInformation()


        let items = ProfileHeaderItem.items
            .map { (type) -> SectionOfProfileInfoData in
                switch type {
                case .editProfile:
                    return SectionOfProfileInfoData(id: "23123",
                                                    items: profileInformation,
                                                    header: .editProfile)
                default:
                    return SectionOfProfileInfoData(id: "23123",
                                                    items: profileInformation,
                                                    header: .editPassword)
                }
        }
        return Observable.just(items)
    }

    private static func generateProfileInformation() -> [ProfileInfoField] {
        var profileInformation: [ProfileInfoField] = []

        profileInformation.append(ProfileInfoField(
            key: "Nama",
            value: "Ali Muda",
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Username",
            value: "@AliMuda",
            fieldType: .username
        ))
        profileInformation.append(ProfileInfoField(
            key: "Lokasi",
            value: "Godean",
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Deskripsi Tentang Kamu",
            value: "Godean Ale",
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Pendidikan",
            value: "Universitas Godean Ale",
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Pekerjaan",
            value: "Ale",
            fieldType: .text
        ))
        return profileInformation
    }
}
