//
//  PedestrianService.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/31.
//

import Foundation
import Alamofire

struct PedestrianService {
    static let shared = PedestrianService()
    
    func getPedestrianRoute(startX: Double, startY: Double, endX: Double, endY: Double, startName: String, endName: String, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        
        let url = APIConstants.hapticRoadBaseURL
        let header: HTTPHeaders = [ "Accept":"application/json"]
        let body: Parameters = [
            "startX" : startX,
            "startY" : startY,
            "endX" : endX,
            "endY" : endY,
            "startName" : startName,
            "endName" : endName
        ]
        let dataRequest = AF.request(url,
                                     method: .post,
                                     parameters: body,
                                     encoding: JSONEncoding.default,
                                     headers: header)
        
        dataRequest.responseData { (response) in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return
                }
                guard let data = response.value else {
                    return
                }
                completion(judgePedestrianData(status: statusCode, data: data))
                
            case .failure(let err): print(err)
                completion(.networkFail) }
        }
    }
    
    private func judgePedestrianData(status: Int, data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(GenericResponse<PedestrianData>.self, from: data) else {
            print("here//?")
            return .pathErr
        }
        switch status {
        case 200:
            print("성공")
            return .success(decodedData.data ?? "None-Data")
        case 400..<500:
            return .requestErr(decodedData.message)
        case 500:
            return .serverErr
        default:
            return .networkFail
        }
    }
}

