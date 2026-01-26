//
//  SearchCollectionViewCell.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//

import UIKit

import Kingfisher
import SnapKit



final class SearchCollectionViewCell: UICollectionViewCell {

    private lazy var imageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFill
        result.clipsToBounds = true
        return result
    }()

    static let processor = DownsamplingImageProcessor(size: LayoutConstant.thumbnailPosterSize)

    private lazy var optimizedScale: CGFloat = {
        // 3.0 기기에서도 1.5의 해상도만 사용
        let minScaleValue: CGFloat = 1.5
        let deviceScale = UIScreen.main.scale
        return min(deviceScale, minScaleValue)
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
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

    func configure(_ item: ImageDetail) {

        imageView.kf
            .setImage(
                with: URL(string: item.urls.small),
                options: [
                    .processor(Self.processor),
                    .scaleFactor(optimizedScale),
                    .cacheSerializer(FormatIndicatedCacheSerializer.jpeg),
                    .transition(.fade(0.2))
                ]
            )
    }
}

extension SearchCollectionViewCell: BasicViewProtocol {
    func configureHierarchy() {
        contentView.addSubview(imageView)
    }

    func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configureView() {
    }
}
