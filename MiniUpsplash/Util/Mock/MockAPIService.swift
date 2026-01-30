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

    func getSearch(_ searchDto: SearchRequestDTO) async throws ->  Result<SearchResponseDTO, any Error> {
        let urlStr = "https://mock-0527eea38e7d41a490d2347a55302361.mock.insomnia.run/search/photos"

        let result = try await AF.request(urlStr)
            .validate()
            .serializingDecodable(SearchResponseDTO.self)
            .value

        return .success(result)
    }

    func getTopic(_ topicRequestDto: TopicRequestDTO) async throws -> Result<[ImageDetail], any Error> {
        let urlStr = "https://mock-0527eea38e7d41a490d2347a55302361.mock.insomnia.run/topics/architecture-interior/photos"

        let result = try await AF.request(urlStr)
            .validate()
            .serializingDecodable([ImageDetail].self)
            .value

        return .success(result)
    }

    func getTopic(_ topicRequestDto: TopicRequestDTO, _ completion: @escaping (Result<[ImageDetail], any Error>) -> Void) {
        let urlStr = "https://mock-0527eea38e7d41a490d2347a55302361.mock.insomnia.run/topics/architecture-interior/photos"

        AF.request(urlStr)
        .validate()
        .responseDecodable(of: [ImageDetail].self) { response in
            completion(response.result.mapError({ afError in
                APIError.default(message: afError.localizedDescription)
            }))
        }
    }

    func getStatistic(_ imageId: String) async throws -> Result<StaticResponseDTO, any Error> {
        let url = "https://mock-0527eea38e7d41a490d2347a55302361.mock.insomnia.run/photos/QvIEolyJAIQ/statistics"

        let result = try await AF.request(url)
            .validate()
            .serializingDecodable(StaticResponseDTO.self)
            .value

        return .success(result)
    }
}
