//
//  UILabel+ext.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import UIKit

extension UILabel {
    func setSectionHeader() {
        font = .boldSystemFont(ofSize: 22)
        textColor = .black
        numberOfLines = 0
        textAlignment = .left
    }
}
