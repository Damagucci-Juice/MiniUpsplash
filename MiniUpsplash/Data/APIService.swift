//
//  APIService.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//
import Foundation

import Alamofire

struct SearchRequestDTO {
    let query: String
    let page: Int?          // default 1
    let perPage: Int?       // default 10, max 30
    let orderBy: OrderBy?
    let color: ColorParam?

    func makeParam() -> Parameters {
        var result: Parameters = [ "query" : query ]
        if let page { result.updateValue(page, forKey: "page") }
        if let perPage { result.updateValue(perPage, forKey: "per_page") }
        if let orderBy { result.updateValue(orderBy.text, forKey: "order_by") }
        if let color { result.updateValue(color.text, forKey: "color") }
        return result
    }
}

//enum ImageAPIError: Error {
//    case urlFailure
//}

final class APIService {
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
}
