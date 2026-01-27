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
