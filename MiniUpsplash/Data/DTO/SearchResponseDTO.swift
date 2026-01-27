//
//  SearchResponse.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//

import Foundation

struct SearchResponseDTO: Decodable {
    let total: Int
    let total_pages: Int
    let results: [ImageDetail]
    
}

struct ImageDetail: Decodable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let urls: URLs
    let likes: Int
    let user: User

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case urls
        case likes
        case user
    }
}

struct User: Decodable {
    let id: String
    let username: String
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable {
    let medium: String
}

struct URLs: Decodable {
    let raw: String
    let small: String
}
