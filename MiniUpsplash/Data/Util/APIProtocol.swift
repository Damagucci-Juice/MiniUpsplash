//
//  APIProtocol.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//
import Foundation

protocol APIProtocol {
    func getSearch(_ searchDto: SearchRequestDTO) async throws ->  Result<SearchResponseDTO, any Error>
    func getTopic(_ topicRequestDto: TopicRequestDTO) async throws -> Result<[ImageDetail], any Error>
    func getTopic(_ topicRequestDto: TopicRequestDTO,
                  _ completion: @escaping (Result<[ImageDetail], any Error>) -> Void)

    func getStatistic(_ imageId: String) async throws -> Result<StaticResponseDTO, any Error>
}
