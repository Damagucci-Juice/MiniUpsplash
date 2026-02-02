//
//  UpsplashRouter.swift
//  MiniUpsplash
//
//  Created by Gucci on 2/2/26.
//
import Foundation
import Alamofire

enum UpsplashRouter: URLRequestConvertible {
    case search(SearchRequestDTO)
    case topic(TopicRequestDTO)
    case statistics(id: Int)

    var baseURL: String { "https://api.unsplash.com" }

    var path: String {
        switch self {
        case .search:
            return "/search/photos"
        case .topic(let topicDTO):
            return "/topics" + topicDTO.kind.queryPath + "/photos"
        case .statistics(let id):
            return "/photos" + "/" + "\(id)" + "/statistics"
        }
    }

    var endpoint: String {
        #if DEBUG
        switch self {
        case .search(let searchRequestDTO):
            return "https://mock-0527eea38e7d41a490d2347a55302361.mock.insomnia.run/search/photos"
        case .topic(let topicRequestDTO):
            return "https://mock-0527eea38e7d41a490d2347a55302361.mock.insomnia.run/topics/architecture-interior/photos"
        case .statistics(let id):
            return "https://mock-0527eea38e7d41a490d2347a55302361.mock.insomnia.run/photos/QvIEolyJAIQ/statistics"
        }
        #else
        return baseURL + path
        #endif
    }

    var method: HTTPMethod { return .get }

    var param: [String: Any] {
        switch self {
        case .search(let searchRequestDTO):
            return searchRequestDTO.makeParam()
        case .topic(let topicRequestDTO):
            return topicRequestDTO.makeParam()
        case .statistics:
            return [:]
        }
    }

    var header: HTTPHeaders {
        [
            HTTPHeader(name: APIKey.authHeaderKey, value: APIKey.authHeaderValue),
            HTTPHeader(name: APIKey.versionHeaderKey, value: APIKey.versionHeaderValue),
        ]
    }

    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw AFError.parameterEncodingFailed(reason: .missingURL)
        }

        var request = URLRequest(url: url)
        request.method = method
        request.headers = header

        // 3. 파라미터 인코딩 (GET 방식이므로 쿼리 파라미터로 인코딩)
        // 만약 POST 방식이고 JSON 바디가 필요하다면 JSONEncoding.default를 사용해야 합니다.
        return try URLEncoding.default.encode(request, with: param)
    }
}
