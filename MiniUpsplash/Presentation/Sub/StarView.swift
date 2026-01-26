//
//  StarView.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import UIKit

import SnapKit

final class StarView: UIView {
    private let capsuleView = {
        let result = UIView()
        result.backgroundColor = .systemGray
        result.clipsToBounds = true
        return result
    }()

    private let starImageView = {
        let result = UIImageView(image: UIImage(systemName: "star.fill")?
            .withTintColor(.yellow, renderingMode: .alwaysTemplate))
        result.backgroundColor = .clear
        result.tintColor = .yellow
        return result
    }()

    private let countLabel = {
        let result = UILabel()
        result.font = .systemFont(ofSize: 11)
        result.textColor = .white
        result.numberOfLines = 1
        return result
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setInfo(_ count: Int) {
        capsuleView.isHidden = count == 0
        countLabel.text = NumberManager.shared.convert(count)
    }
}

extension StarView: BasicViewProtocol {
    func configureHierarchy() {
        addSubview(capsuleView)
        capsuleView.addSubview(starImageView)
        capsuleView.addSubview(countLabel)
    }
    
    func configureLayout() {
        self.snp.makeConstraints { make in
            make.height.equalTo(LayoutConstant.capsuleSize.height)
            make.width.greaterThanOrEqualTo(LayoutConstant.capsuleSize.width)
        }

        capsuleView.snp.makeConstraints { make in
            make.height.equalTo(LayoutConstant.capsuleSize.height)
            make.width.greaterThanOrEqualTo(LayoutConstant.capsuleSize.width)
            make.center.equalToSuperview()
        }

        starImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(LayoutConstant.capsulePaddingLeading)
            make.size.equalTo(LayoutConstant.starSize)
        }

        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(starImageView.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(LayoutConstant.capsulePaddingLeading)
        }
    }
    
    func configureView() {
        backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.capsuleView.setCorner(self.capsuleView.bounds.height / 2)
        }
    }
}
