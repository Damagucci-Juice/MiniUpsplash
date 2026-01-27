//
//  TopicRequestDTO.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import Foundation

struct TopicRequestDTO: Parameterable {
    let page: Int?
    let kind: TopicSubject
}
