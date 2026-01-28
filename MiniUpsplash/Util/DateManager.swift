//
//  DateManager.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/28/26.
//

import Foundation

final class DateManager {
    static let shared = DateManager()

    private let formatter = {
        let result = DateFormatter()
        result.dateFormat = "yyyy년 M월 D일"
        return result
    }()


    // param origin : 2022-03-22T04:41:46Z
    // return       : 2022년 3월 22일
    func convert(origin: String) -> String? {
        if let date = try? Date(origin, strategy: .iso8601) {
            return formatter.string(from: date)
        }

        return origin
    }

    private init() { }
}
