//
//  StaticResponseDTO.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/28/26.
//

import Foundation

struct StaticResponseDTO: Decodable {
    let id: String
    let downloads: DownloadInfo
    let views: ViewInfo
}

struct DownloadInfo: Decodable {
    let total: Int
    let historical: Historical
}

struct Historical: Decodable {
    let change: Int
    let resolution: String
    let quantity: Int
    let values: [ValueInfo]
}

struct ValueInfo: Decodable, Identifiable {
    let id = UUID()
    let date: String
    let value: Int

    enum CodingKeys: CodingKey {
        case date
        case value
    }
}

struct ViewInfo: Decodable {
    let total: Int
    let historical: Historical
}
