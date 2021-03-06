//
//  PreTestAPI.swift
//  PreTest
//
//  Created by alpiopio on 15/01/20.
//  Copyright © 2020 alpiopio. All rights reserved.
//

import Foundation

enum PreTestAPI {
    case register(phone: String, password: String, country: String, latlong: String, deviceToken: String)
    case otpRequest(phone: String)
    case otpMatch(userId: String, otpCode: String)
    case profile
    case logout
    case login(phone: String, password: String, latlong: String, deviceToken: String)
    case updateEducation(name: String, graduation: String)
    case updateCareer(position: String, name: String, start: String, end: String)
    case updateCover(image: Media)
    case updateProfile(image: Media)
    case setDefault(id: String)
    case message(id: String, message: String)
}

extension PreTestAPI: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: "http://pretest-qa.privydev.id/api/v1/") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .register:
            return "register"
        case .otpRequest:
            return "register/otp/request"
        case .otpMatch:
            return "register/otp/match"
        case .profile:
            return "profile/me"
        case .logout:
            return "oauth/revoke"
        case .login:
            return "oauth/sign_in"
        case .updateEducation:
            return "profile/education"
        case .updateCareer:
            return "profile/career"
        case .updateCover:
            return "uploads/cover"
        case .updateProfile:
            return "uploads/profile"
        case .setDefault:
            return "uploads/profile/default"
        case .message:
            return "message/send"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .register(let (phone, password, country, latlong, deviceToken)):
            return [
                "phone": phone,
                "password": password,
                "country": country,
                "latlong": latlong,
                "device_token": deviceToken,
                "device_type": 1
            ]
        case .otpRequest(let phone):
            return [
                "phone": phone
            ]
        case .otpMatch(let (userId, otpCode)):
            return [
                "user_id": userId,
                "otp_code": otpCode
            ]
        case .logout:
            return [
                "access_token": UserDefaults.standard.string(forKey: Constant.userDefaults.accessToken) ?? "",
                "confirm": 1
            ]
        case.login(let (phone, password, latlong, deviceToken)):
            return [
                "phone": phone,
                "password": password,
                "latlong": latlong,
                "device_token": deviceToken,
                "device_type": 1
            ]
        case .updateEducation(let (name, graduation)):
            return [
                "school_name": name,
                "graduation_time": graduation
            ]
        case .updateCareer(let (position, name, start, end)):
            return [
                "position": position,
                "company_name": name,
                "starting_from": start,
                "ending_in": end
            ]
        case .setDefault(let id):
            return [
                "id": id
            ]
        case .message(let (id, message)):
            return [
                "user_id": id,
                "message": message
            ]
        default:
            return nil
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .register,
             .otpRequest,
             .otpMatch,
             .logout,
             .login,
             .updateEducation,
             .updateCareer,
             .updateCover,
             .updateProfile,
             .setDefault,
             .message:
            return .post
        default:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .register,
             .otpRequest,
             .otpMatch,
             .logout,
             .login,
             .updateEducation,
             .updateCareer,
             .setDefault,
             .message:
            return .requestParameters(parameters: parameters ?? [:], encoding: .jsonEncoding)
        case .updateCover(let image):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(MultipartFormData(provider: .data(image.data), name: image.key, filename: image.filename, mimeType: image.mimeType))
            return .uploadMultipart(multipartFormData: multipartFormData)
        case .updateProfile(let image):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(MultipartFormData(provider: .data(image.data), name: image.key, filename: image.filename, mimeType: image.mimeType))
            return .uploadMultipart(multipartFormData: multipartFormData)
        default:
            return .request
        }
    }
    
    var header: [String : String]? {
        switch self {
        case .profile,
             .updateEducation,
             .updateCareer,
             .updateCover,
             .updateProfile,
             .setDefault,
             .message:
            let tokenType = UserDefaults.standard.string(forKey: Constant.userDefaults.tokenType) ?? ""
            let accessToken = UserDefaults.standard.string(forKey: Constant.userDefaults.accessToken) ?? ""
            return [
                HTTPHeaderField.authentication.rawValue: tokenType + " " + accessToken,
                HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue
            ]
        default:
            return [
                HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue
            ]
        }
    }
}
