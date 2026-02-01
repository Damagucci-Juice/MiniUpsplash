//
//  UDManager.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/30/26.
//


import Foundation

final class UDManager {
    static let shared = UDManager()

    private init() { }

    var searchKeys: [String] {
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

    var heartImageIds: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: Constant.heartIDUDKey) ?? [])
        }

        set {
            UserDefaults.standard.set(Array(newValue), forKey: Constant.heartIDUDKey)
        }
    }

    func toggleHeart(_ id: String) {
        if heartImageIds.contains(id) {
            heartImageIds.remove(id)
        } else {
            heartImageIds.insert(id)
        }
    }
}
