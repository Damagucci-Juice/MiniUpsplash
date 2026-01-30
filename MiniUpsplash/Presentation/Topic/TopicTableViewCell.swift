//
//  TopicTableViewCell.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/30/26.
//

import UIKit
import SnapKit

final class TopicTableViewCell: UITableViewCell {

    private var topic: TopicSubject?
    private var dataSource = [ImageDetail]()

    private let sectionHeaderLabel: UILabel = {
        let label = UILabel()
        label.setSectionHeader()
        return label
    }()

    var onImageTapped: ((ImageDetail) -> Void)?

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureLayout()
        configureView()
    }

    @available(*,unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sectionHeaderLabel.text = nil
        collectionView.reloadData()
        topic = nil
        onImageTapped = nil 
    }

    func configureItem(topic: TopicSubject, _ item: [ImageDetail], _ completionHandler: (Result<Void, any Error>) -> Void) {
        self.dataSource = item
        self.topic = topic
        sectionHeaderLabel.text = topic.description
        collectionView.reloadData()
    }

    func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let hInset = 10.0
        let vInset = 0.0
        let lineSpacing = 20.0
        let interSpacing = 1.0

        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = interSpacing
        let itemPerRow = 2.0
        let itemPerCol = 1.0
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - (hInset * 2) - (interSpacing * (itemPerRow - 1))
        let cellWidth = availableWidth / itemPerRow

        let collectionViewHeight = collectionView.bounds.height
        let availableHeight = collectionViewHeight - (vInset * 2) - (lineSpacing * (itemPerCol))
        let cellHeight = availableHeight / itemPerCol
        layout.itemSize = CGSize(
            width: cellWidth,
            height: cellHeight)
        layout.sectionInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
        return layout
    }

    func configureCollectionSection(label: UILabel, collectionView: UICollectionView) {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SearchCollectionViewCell.self,
                                forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            collectionView.collectionViewLayout = self.layout()
        }

    }
}

extension TopicTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell() }

        cell.configure(dataSource[indexPath.item])
        cell.setCorner(16)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)

        onImageTapped?(dataSource[indexPath.item])
    }
}

extension TopicTableViewCell: BasicViewProtocol {
    func configureHierarchy() {
        contentView.addSubview(sectionHeaderLabel)
        contentView.addSubview(collectionView)
    }
    
    func configureLayout() {
        sectionHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(8)
            make.horizontalEdges.equalTo(contentView).inset(16)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(sectionHeaderLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(contentView)
            make.bottom.equalTo(contentView).inset(8)
        }
    }
    
    func configureView() {
        configureCollectionSection(label: sectionHeaderLabel, collectionView: collectionView)
    }
}
