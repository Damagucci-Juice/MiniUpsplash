//
//  TopicSubject.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import Foundation

enum TopicSubject: CaseIterable, CustomStringConvertible {
    case architectureInterior
    case goldenHour
    case wallpapers
    case nature
    case renders3D
    case travel
    case pattern
    case street
    case film
    case archival
    case experimental
    case animals
    case fashionBeauty
    case people
    case businessWork
    case foodDrink

    var description: String {
        switch self {
        case .architectureInterior: return "건축 및 인테리어"
        case .goldenHour:           return "골든 아워"
        case .wallpapers:           return "배경 화면"
        case .nature:               return "자연"
        case .renders3D:            return "3D 렌더링"
        case .travel:               return "여행하다"
        case .pattern:              return "텍스쳐 및 패턴"
        case .street:               return "거리 사진"
        case .film:                 return "필름"
        case .archival:             return "기록의"
        case .experimental:         return "실험적인"
        case .animals:              return "동물"
        case .fashionBeauty:        return "패션 및 뷰티"
        case .people:               return "사람"
        case .businessWork:         return "비즈니스 및 업무"
        case .foodDrink:            return "식음료"
        }
    }

    var queryPath: String {
        switch self {
        case .architectureInterior: return "/architecture-interior"
        case .goldenHour:           return "/golden-hour"
        case .wallpapers:           return "/wallpapers"
        case .nature:               return "/nature"
        case .renders3D:            return "/3d-renders"
        case .travel:               return "/travel"
        case .pattern:              return "/textures-patterns"
        case .street:               return "/street-photography"
        case .film:                 return "/film"
        case .archival:             return "/archival"
        case .experimental:         return "/experimental"
        case .animals:              return "/animals"
        case .fashionBeauty:        return "/fashion-beauty"
        case .people:               return "/people"
        case .businessWork:         return "/business-work"
        case .foodDrink:            return "/food-drink"
        }
    }

    static func randomElement(for num: Int) -> [TopicSubject] {
        var result = Set<TopicSubject>()
        while result.count < num {
            result.insert(allCases.randomElement()!)
        }
        return Array(result)
    }
}
