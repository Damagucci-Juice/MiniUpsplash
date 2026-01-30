//
//  UDManager.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/30/26.
//


import Foundation

final class UDManager {
    static var searchKeys: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: Constant.recentSearchUDKey) ?? []
        }
        set {
            var seen = Set<String>()
            var result = [String]()
            for str in newValue where !seen.contains(str) {
                result.append(str)
                seen.insert(str)
            }
            UserDefaults.standard.set(result, forKey: Constant.recentSearchUDKey)
        }
    }
}
