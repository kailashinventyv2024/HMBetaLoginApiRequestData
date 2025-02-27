//
//  LoginRequestModel.swift
//  HMBetaLoginApiRequestData
//
//  Created by Kailash Rajput on 25/02/25.
//

import Foundation

struct LoginRequestModel: Codable{
    var userName: String
    var password: String
    var SoftwareType: String
    var ReleaseVersion: String
}
