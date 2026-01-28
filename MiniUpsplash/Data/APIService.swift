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

    private let header: HTTPHeaders = [
        HTTPHeader(name: APIKey.authHeaderKey, value: APIKey.authHeaderValue),
        HTTPHeader(name: APIKey.versionHeaderKey, value: APIKey.versionHeaderValue),
    ]

    private init() { }

    func getSearch(_ searchDto: SearchRequestDTO) async throws ->  Result<SearchResponseDTO, any Error> {
        let urlStr = Constant.baseUrl + Constant.searchPath
        let param = searchDto.makeParam()


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

        let result = try await AF.request(urlStr,
                                          method: .get,
                                          parameters: param,
                                          headers: header)
            .validate()
            .serializingDecodable([ImageDetail].self)
            .value

        return .success(result)
    }

    func getStatistic(_ imageId: String) async throws -> Result<StaticResponseDTO, any Error> {
        let url = Constant.baseUrl + "/photos" + "/" + imageId + "/statistics"

        let result = try await AF.request(url,
                                          method: .get,
                                          headers: header)
            .validate()
            .serializingDecodable(StaticResponseDTO.self)
            .value

        return .success(result)
    }

}
