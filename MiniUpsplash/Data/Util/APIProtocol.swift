//
//  APIProtocol.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//
import Foundation

protocol APIProtocol {
    func fetch<T>(api: UpsplashRouter) async -> Result<T, UpsplashError> where T: Decodable
    func fetch<T>(api: UpsplashRouter, type: T.Type, completionHandler: @escaping (Result<T, UpsplashError>) -> Void) where T : Decodable
}
