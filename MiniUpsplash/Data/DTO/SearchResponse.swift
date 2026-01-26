//
//  SearchResponse.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//

import Foundation

enum OrderBy {
    case relevant
    case latest

    var text: String {
        switch self {
        case .relevant:
            return "relevant"
        case .latest:
            return "latest"
        }
    }
}

enum ColorParam {
    case blackAndWhite
    case black
    case white
    case yellow
    case orange
    case red
    case purple
    case magenta
    case green
    case teal
    case blue

    var text: String {
        switch self {
        case .blackAndWhite:
            return "black_and_white"
        case .black:
            return "black"
        case .white:
            return "white"
        case .yellow:
            return "yellow"
        case .orange:
            return "orange"
        case .red:
            return "red"
        case .purple:
            return "purple"
        case .magenta:
            return "magenta"
        case .green:
            return "green"
        case .teal:
            return "teal"
        case .blue:
            return "blue"
        }
    }
}

struct SearchResponseDTO: Decodable {
    let total: Int
    let total_pages: Int
    let results: [ImageDetail]
    
}

struct ImageDetail: Decodable {
    let id: String
    let created_at: String
    let updated_at: String
    let width: Int
    let height: Int
    let color: String
    let urls: URLs
    let likes: Int
    let asset_type: String
    let user: User
}

struct User: Decodable {
    let id: String
    let username: String
    let profile_image: [ProfileImage]
}

struct ProfileImage: Decodable {
    let small: String
}

struct URLs: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let small_s3: String
}
