//
//  UIImage+ext.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/28/26.
//

import UIKit

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }

        return image.withRenderingMode(renderingMode)
    }
}
