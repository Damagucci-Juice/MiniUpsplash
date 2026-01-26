//
//  BasicReusableProtocol.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//

import UIKit

protocol ReusableViewProtocol {
    static var identifier: String { get }
}

extension ReusableViewProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIViewController: ReusableViewProtocol { }

extension UITableViewCell: ReusableViewProtocol { }


extension UICollectionViewCell: ReusableViewProtocol { }
