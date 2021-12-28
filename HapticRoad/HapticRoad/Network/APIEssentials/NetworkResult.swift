//
//  NetworkResult.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/04.
//

import Foundation

enum NetworkResult<T> {
    case success(T)
    case requestErr(T)
    case pathErr
    case serverErr
    case networkFail
}
