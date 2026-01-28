//
//  NumberManager.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//
import Foundation

final class NumberManager {
    static let shared = NumberManager()
    private let formatter = NumberFormatter()

    private init() {
        self.formatter.numberStyle = .decimal
    }

    func convert(_ num: Int) -> String {
        guard let result = formatter.string(from: num as NSNumber) else { return "\(num)" }
        return result
    }
}
