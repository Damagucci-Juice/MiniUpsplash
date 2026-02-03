//
//  MockAPIService.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import Foundation

import Alamofire

final class MockAPIService: APIProtocol {

    static let shared = MockAPIService()

    private init() { }

    func fetch<T>(api: UpsplashRouter) async -> Result<T, UpsplashError> where T : Decodable {
        await AF.request(api.endpoint)
           .validate()
           .serializingDecodable(T.self)
           .result
           .mapError { afError in
               if let status = afError.responseCode {
                   return UpsplashError(rawValue: status) ?? .unknown
               }
               return .unknown
           }
    }

    func fetch<T>(api: UpsplashRouter, type: T.Type, completionHandler: @escaping (Result<T, UpsplashError>) -> Void) where T : Decodable {
        AF.request(api.endpoint)
        .validate()
        .responseDecodable(of: type) { response in
            if let statusCode = response.response?.statusCode, let upsplashError = UpsplashError(rawValue: statusCode) {
                completionHandler(.failure(upsplashError))
                return
            }

            if let success = try? response.result.get() {
                completionHandler(.success(success))
            } else {
                completionHandler(.failure(.unknown))
            }
        }
    }
}
