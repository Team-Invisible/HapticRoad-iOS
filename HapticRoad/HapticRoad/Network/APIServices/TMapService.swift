//
//  TMapService.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/04.
//

import Foundation
import Moya

enum TMapService {
    case pedestrianRouteData(startX: Double, startY: Double, endX: Double, endY: Double, startName: String, endName: String)
    case poisData(searchKeyword: String, centerLon: Double, centerLat: Double)
}

extension TMapService: TargetType {
    var baseURL: URL {
        return URL(string: APIConstants.hapticRoadBaseURL)!
    }
    
    var path: String {
        switch self {
            
        case .pedestrianRouteData:
            return ""
        case .poisData:
            return "/search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .pedestrianRouteData:
            return .post
        case .poisData:
            return .get
        }
    }
    
    var task: Task {
        switch self {
            
        case .pedestrianRouteData(let startX, let startY, let endX, let endY, let startName, let endName):
            print("startX: \(startX)","startY: \(startY)", "endX: \(endX)", "endY: \(endY)", "startName: \(startName)", "endName : \(endName)")
            return .requestParameters(parameters: [
                "startX" : startX,
                "startY": startY,
                "endX": endX,
                "endY": endY,
                "startName": startName,
                "endName" : endName
            ], encoding: JSONEncoding.default)
            
        case .poisData(let searchKeyword, let centerLon, let centerLat):
            return .requestParameters(parameters: [
                "searchKeyword" : searchKeyword,
                "centerLon" : centerLon,
                "centerLat" : centerLat
            ], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
