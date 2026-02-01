//
//  RecentKeywordTableViewCell.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/30/26.
//


import UIKit

import SnapKit

final class RecentKeywordTableViewCell: UITableViewCell, BasicViewProtocol {

    private lazy var keyLabel = {
        let result = UILabel()
        result.setBody()
        return result
    }()

    private(set) lazy var removeButton = {
        let result = UIButton()
        result.backgroundColor = .clear
        result.setImage(.init(systemName: "xmark"), for: .normal)
        result.tintColor = .lightGray
        return result
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        keyLabel.text = nil
        removeButton.removeTarget(self, action: nil, for: .touchUpInside)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ key: String) {
        keyLabel.text = key
    }

    func configureHierarchy() {
        contentView.addSubview(keyLabel)
        contentView.addSubview(removeButton)
    }
    
    func configureLayout() {
        keyLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalTo(removeButton.snp.leading).offset(-8)
        }

        removeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    func configureView() {
        contentView.backgroundColor = .white
    }
}
