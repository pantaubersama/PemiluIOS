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
    static func profileInfoData(data: User) -> Observable<[SectionOfProfileInfoData]> {
        let profileInformation = generateProfileInformation(data)
        let generateUbahSandiInformation = generateUbahSandi(data)
        let generateDataLaporInformation = generateDataLapor(data)

        let items = ProfileHeaderItem.items
            .map { (type) -> SectionOfProfileInfoData in
                switch type {
                case .editProfile:
                    return SectionOfProfileInfoData(id: data.id,
                                                    items: profileInformation,
                                                    header: .editProfile)
                case .editPassword:
                    return SectionOfProfileInfoData(id: data.id,
                                                    items: generateUbahSandiInformation,
                                                    header: .editPassword)
                case .editDataLapor:
                    return SectionOfProfileInfoData(id: data.id,
                                                    items: generateDataLaporInformation,
                                                    header: .editDataLapor)
                }
        }
        return Observable.just(items)
    }

    private static func generateProfileInformation(_ data: User) -> [ProfileInfoField] {
        var profileInformation: [ProfileInfoField] = []

        profileInformation.append(ProfileInfoField(
            key: "Nama",
            value: data.firstName,
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Username",
            value: data.lastName,
            fieldType: .username
        ))
        profileInformation.append(ProfileInfoField(
            key: "Lokasi",
            value: data.lastName,
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Deskripsi Tentang Kamu",
            value: data.lastName,
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Pendidikan",
            value: data.lastName,
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Pekerjaan",
            value: data.lastName,
            fieldType: .text
        ))
        return profileInformation
    }
    
    private static func generateUbahSandi(_ data: User) -> [ProfileInfoField] {
        let sandiInformation: [ProfileInfoField] = []
        
        return sandiInformation
    }
    
    private static func generateDataLapor(_ data: User) -> [ProfileInfoField] {
        let dataLaporInformation: [ProfileInfoField] = []
        return dataLaporInformation
    }
}
