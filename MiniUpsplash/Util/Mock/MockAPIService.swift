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

    func fetch<T>(api: UpsplashRouter) async -> Result<T, any Error> where T : Decodable {
        await AF.request(api.endpoint)
           .validate()
           .serializingDecodable(T.self)
           .result
           .mapError({ $0 as Error })
    }

    func fetch<T>(api: UpsplashRouter, type: T.Type, completionHandler: @escaping (Result<T, any Error>) -> Void) where T : Decodable {
        AF.request(api.endpoint)
        .validate()
        .responseDecodable(of: type) { response in
            completionHandler(response.result.mapError({ afError in
                APIError.default(message: afError.localizedDescription)
            }))
        }
    }

}
