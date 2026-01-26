//
//  UIView+ext.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import UIKit

extension UIView {
    func setCorner(_ value: CGFloat) {
        layer.cornerRadius = value
        clipsToBounds = true
    }

    func setBorder(_ value: CGFloat, color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = value
    }
}
