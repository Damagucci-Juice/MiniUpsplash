//
//  APIProtocol.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//
import Foundation

protocol APIProtocol {
    func fetch<T>(api: UpsplashRouter) async -> Result<T, any Error> where T: Decodable
    func fetch<T>(api: UpsplashRouter, completionHandler: @escaping (Result<T, any Error>) -> Void) where T: Decodable
}
