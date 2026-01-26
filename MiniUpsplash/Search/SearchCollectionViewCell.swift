//
//  SearchCollectionViewCell.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//

import UIKit

final class SearchCollectionViewCell: UICollectionViewCell {

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchCollectionViewCell: BasicViewProtocol {
    func configureHierarchy() {

    }

    func configureLayout() {

    }

    func configureView() {
    }
}
