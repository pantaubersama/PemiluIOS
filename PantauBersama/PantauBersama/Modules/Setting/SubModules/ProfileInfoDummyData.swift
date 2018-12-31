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
    
    var headerView: UIView? {
        switch self {
        case .editProfile:
            return HeaderEditProfile()
        case .editDataLapor:
            return HeaderDataLapor()
        default:
            return UIView()
        }
    }
    
    var sizeHeader: CGFloat {
        switch self {
        case .editProfile:
            return 172.0
        case .editDataLapor:
            return 130.0
        case .editPassword:
            return 48.0
        }
    }
}

final class ProfileInfoDummyData {
    static func profileInfoData(data: User, type: ProfileHeaderItem) -> Observable<[SectionOfProfileInfoData]> {
        let profileInformation = generateProfileInformation(data)
        let generateUbahSandiInformation = generateUbahSandi(data)
        let generateDataLaporInformation = generateDataLapor(data)
        
        var item: [SectionOfProfileInfoData] = []
        switch type {
        case .editProfile:
            item.append(SectionOfProfileInfoData(id: data.id,
                                                 items: profileInformation,
                                                 header: .editProfile))
        case .editPassword:
            item.append(SectionOfProfileInfoData(id: data.id,
                                                 items: generateUbahSandiInformation,
                                                 header: .editPassword))
        case .editDataLapor:
            item.append(SectionOfProfileInfoData(id: data.id,
                                                 items: generateDataLaporInformation,
                                                 header: .editDataLapor))
        }
        return Observable.just(item)
    }

    private static func generateProfileInformation(_ data: User) -> [ProfileInfoField] {
        var profileInformation: [ProfileInfoField] = []

        profileInformation.append(ProfileInfoField(
            key: .nama,
            value: data.firstName,
            fieldType: .text,
            parameter: "first_name"
        ))
        profileInformation.append(ProfileInfoField(
            key: .username,
            value: data.username,
            fieldType: .username,
            parameter: "username"
        ))
        profileInformation.append(ProfileInfoField(
            key: .address,
            value: data.location,
            fieldType: .text,
            parameter: "location"
        ))
        profileInformation.append(ProfileInfoField(
            key: .about,
            value: data.about,
            fieldType: .text,
            parameter: "about"
        ))
        profileInformation.append(ProfileInfoField(
            key: .pendidikan,
            value: data.education,
            fieldType: .text,
            parameter: "education"
        ))
        profileInformation.append(ProfileInfoField(
            key: .pekerjaan,
            value: data.occupation,
            fieldType: .text,
            parameter: "occupation"
        ))
        return profileInformation
    }
    
    private static func generateUbahSandi(_ data: User) -> [ProfileInfoField] {
        var sandiInformation: [ProfileInfoField] = []
        
        sandiInformation.append(ProfileInfoField(
            key: .sandiLama,
            value: "123123",
            fieldType: .password,
            parameter: ""
        ))
        
        sandiInformation.append(ProfileInfoField(
            key: .sandiBaru,
            value: "123123",
            fieldType: .password,
            parameter: ""
        ))
        
        sandiInformation.append(ProfileInfoField(
            key: .sandiKonfirmasi,
            value: "123123",
            fieldType: .password,
            parameter: ""
        ))
        
        return sandiInformation
    }
    
    private static func generateDataLapor(_ data: User) -> [ProfileInfoField] {
        var dataLaporInformation: [ProfileInfoField] = []
        
        dataLaporInformation.append(ProfileInfoField(
            key: .identitas,
            value: "231312323",
            fieldType: .number,
            parameter: "identity_number"
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: .pob,
            value: "Yogyakarta",
            fieldType: .text,
            parameter: "pob"
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: .gender,
            value: "Laki-laki",
            fieldType: .gender,
            parameter: "gender"
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: .pekerjaan,
            value: "PNS",
            fieldType: .text,
            parameter: "occupation"
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: .nationality,
            value: "Indonesia",
            fieldType: .text,
            parameter: "nationality"
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: .address,
            value: "Jalan Viva La",
            fieldType: .text,
            parameter: "address"
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: .phone,
            value: "0239929333",
            fieldType: .text,
            parameter: "phone_number"
        ))
        
        return dataLaporInformation
    }
}
