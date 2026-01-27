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

    func getSearch(_ searchDto: SearchRequestDTO) async throws ->  Result<SearchResponseDTO, any Error> {
        let urlStr = Constant.baseUrl + Constant.searchPath
        let param = searchDto.makeParam()
        let header: HTTPHeaders = [
            HTTPHeader(name: APIKey.authHeaderKey, value: APIKey.authHeaderValue),
            HTTPHeader(name: APIKey.versionHeaderKey, value: APIKey.versionHeaderValue),
        ]

        let result = try await AF.request(urlStr,
                                          method: .get,
                                          parameters: param,
                                          headers: header)
            .validate()
            .serializingDecodable(SearchResponseDTO.self)
            .value

        return .success(result)
    }

    func getTopic(_ dto: TopicRequestDTO) async throws -> Result<[ImageDetail], any Error> {
        let urlStr = Constant.baseUrl + "/topics" + dto.kind.queryPath + "/photos"
        let param = dto.makeParam()
        let header: HTTPHeaders = [
            HTTPHeader(name: APIKey.authHeaderKey, value: APIKey.authHeaderValue),
            HTTPHeader(name: APIKey.versionHeaderKey, value: APIKey.versionHeaderValue),
        ]

        let result = try await AF.request(urlStr,
                                          method: .get,
                                          parameters: param,
                                          headers: header)
            .validate()
            .serializingDecodable([ImageDetail].self)
            .value

        return .success(result)
    }
}
