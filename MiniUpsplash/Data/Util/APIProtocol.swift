//
//  APIProtocol.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//
import Foundation

protocol APIProtocol {
    func fetch<T: Decodable>(api: UpsplashRouter) async -> Result<T, any Error>
    func fetch<T: Decodable>(api: UpsplashRouter, completionHandler: @escaping (Result<T, any Error>) -> Void)
}
