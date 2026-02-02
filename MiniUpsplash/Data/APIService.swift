//
//  APIService.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//
import Foundation

import Alamofire

final class APIService: APIProtocol {

    static let shared = APIService()

    private init() { }

    func fetch<T: Decodable>(api: UpsplashRouter) async -> Result<T, any Error> {
        return await AF.request(api.endpoint,
                             method: api.method,
                             parameters: api.param,
                             headers: api.header)
            .validate()
            .serializingDecodable(T.self)
            .result
            .mapError { error in
                error as NSError
            }
    }

    func fetch<T>(api: UpsplashRouter, completionHandler: @escaping (Result<T, any Error>) -> Void) where T : Decodable {
        AF.request(api.endpoint,
                             method: api.method,
                             parameters: api.param,
                             headers: api.header)
        .validate()
        .responseDecodable(of: T.self) { response in
            completionHandler(
                response.result.mapError({ $0 as NSError })
            )
        }
    }

}

enum APIError: Error {
    case `default`(message: String)
}
