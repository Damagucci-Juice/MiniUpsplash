//
//  SearchRequestDTO.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import Foundation

struct SearchRequestDTO: Parameterable {
    let query: String
    let page: Int?          // default 1
    let perPage: Int?       // default 10, max 30
    let orderBy: OrderBy?
    let color: ColorParam?
}
