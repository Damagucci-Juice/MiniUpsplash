//
//  UpsplashError.swift
//  MiniUpsplash
//
//  Created by Gucci on 2/3/26.
//

import Foundation

enum UpsplashError: Int, Error, LocalizedError {
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case serverFail1 = 500
    case serverFail2 = 503
    case unknown = 999

    var errorDescription: String? {
        switch self {
        case .badRequest:
            return "매개변수 실종 등으로 인한 요청 거부"
        case .unauthorized:
            return "부적절한 접근 토큰"
        case .forbidden:
            return "요청을 수행하기 위한 권한 부족"
        case .notFound:
            return "요청 받은 자원의 부재"
        case .serverFail1:
            return "업스플레쉬 서버 문제 1"
        case .serverFail2:
            return "업스플레쉬 서버 문제 2"
        case .unknown:
            return "알 수 없는 에러"
        }
    }
}
