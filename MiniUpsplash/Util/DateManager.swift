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
        result.dateFormat = "yyyy년 M월 d일"
        result.locale = Locale(identifier: "ko_KR")
        return result
    }()

    private let isoFormatter = ISO8601DateFormatter()

    // param origin : 2022-03-22T04:41:46Z
    // return       : 2022년 3월 22일
    func convert(origin: String) -> String? {
        guard let date = isoFormatter.date(from: origin) else {
            return origin
        }

        return formatter.string(from: date)
    }

    private init() { }
}
