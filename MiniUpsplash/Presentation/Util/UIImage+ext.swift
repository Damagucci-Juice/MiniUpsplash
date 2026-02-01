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

extension UIImage {
    static func circleImage(size: CGFloat, color: UIColor, isSplit: Bool = false) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
            let path = UIBezierPath(ovalIn: rect)

            if isSplit {
                let splitPath = UIBezierPath()
                splitPath.move(to: CGPoint(x: 0, y: size))
                splitPath.addLine(to: CGPoint(x: size, y: size))
                splitPath.addLine(to: CGPoint(x: size, y: 0))
                splitPath.close()

                UIColor.black.setFill()
                path.fill()

                context.cgContext.saveGState()
                path.addClip()
                UIColor.white.setFill()
                splitPath.fill()
                context.cgContext.restoreGState()

                UIColor.systemGray4.setStroke()
                path.lineWidth = 0.5
                path.stroke()
            } else {
                // 일반 단색 원
                color.setFill()
                path.fill()
            }
        }
    }
}
