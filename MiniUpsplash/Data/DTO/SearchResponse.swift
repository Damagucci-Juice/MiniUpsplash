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

enum ColorParam: CaseIterable {
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

    var paramValue: String {
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

    var hex: String {
        switch self {
        case .blackAndWhite:
            return "#FFFFFF" //
        case .black:
            return "#000000"
        case .white:
            return "#FFFFFF" //
        case .yellow:
            return "#FFCC00"
        case .orange:
            return "#FF9500"
        case .red:
            return "#FF3B30"
        case .purple:
            return "#AF52DE"
        case .magenta:
            return "#FF2D55"
        case .green:
            return "#34C759"
        case .teal:
            return "#5AC8FA"    // #008080
        case .blue:
            return "#007AFF"
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
    let profile_image: ProfileImage
}

struct ProfileImage: Decodable {
    let small: String
    let medium: String
    let large: String
}

struct URLs: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let small_s3: String
}
