//
//  ColorParam.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//
import Foundation

enum ColorParam: CaseIterable {
    case blackAndWhite
    case black
    case white
    case yellow
    case orange
    case red
    case purple
    case magenta
    case green
    case teal
    case blue

    var text: String {
        switch self {
        case .blackAndWhite:
            return "블랙&화이트"
        case .black:
            return "블랙"
        case .white:
            return "화이트"
        case .yellow:
            return "옐로우"
        case .orange:
            return "오렌지"
        case .red:
            return "레드"
        case .purple:
            return "퍼플"
        case .magenta:
            return "마젠타"
        case .green:
            return "그린"
        case .teal:
            return "틸"
        case .blue:
            return "블루"
        }
    }

    var paramValue: String {
        switch self {
        case .blackAndWhite:
            return "black_and_white"
        case .black:
            return "black"
        case .white:
            return "white"
        case .yellow:
            return "yellow"
        case .orange:
            return "orange"
        case .red:
            return "red"
        case .purple:
            return "purple"
        case .magenta:
            return "magenta"
        case .green:
            return "green"
        case .teal:
            return "teal"
        case .blue:
            return "blue"
        }
    }

    var hex: String {
        switch self {
        case .blackAndWhite:
            return "#FFFFFF" //
        case .black:
            return "#000000"
        case .white:
            return "#FFFFFF" //
        case .yellow:
            return "#FFEF62"
        case .orange:
            return "#FF9500"
        case .red:
            return "#F04452"
        case .purple:
            return "#9636E1"
        case .magenta:
            return "#FF2D55"
        case .green:
            return "#02B946"
        case .teal:
            return "#5AC8FA"    // #008080
        case .blue:
            return "#3C59FF"
        }
    }
}

import UIKit.UIImage

extension ColorParam {
    var circleImage: UIImage? {
        let size: CGFloat = 16 // 버튼 내 이미지 크기
        if self == .blackAndWhite {
            return UIImage.circleImage(size: size, color: .white, isSplit: true)
        } else {
            let color = UIColor(hex: self.hex) ?? .clear
            return UIImage.circleImage(size: size, color: color, isSplit: false)
        }
    }
}
