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

    func fetch<T>(api: UpsplashRouter) async -> Result<T, UpsplashError>  where T: Decodable {
        return await AF.request(api.endpoint,
                             method: api.method,
                             parameters: api.param,
                             headers: api.header)
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
        AF.request(api.endpoint,
                             method: api.method,
                             parameters: api.param,
                             headers: api.header)
        .validate()
        .responseDecodable(of: type) { response in
            if let success = try? response.result.get() {
                completionHandler(.success(success))
            } else {
                if let statusCode = response.response?.statusCode, let upsplashError = UpsplashError(rawValue: statusCode) {
                    completionHandler(.failure(upsplashError))
                    return
                }

                completionHandler(.failure(.unknown))
            }
        }
    }

}
