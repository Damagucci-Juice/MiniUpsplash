//
//  OrderBy.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import Foundation

enum OrderBy {
    case relevant
    case latest

    var paramValue: String {
        switch self {
        case .relevant:
            return "relevant"
        case .latest:
            return "latest"
        }
    }

    var text: String {
        switch self {
        case .relevant:
            return "관련순"
        case .latest:
            return "최신순"
        }
    }
}
