//
//  TopicViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import UIKit

import SnapKit

final class TopicViewController: UIViewController {

    private let service: APIProtocol

    private let firstLabel: UILabel = {
        let label = UILabel()
        label.setSectionHeader()
        return label
    }()

//    private let secondLabel: UILabel = {
//        let label = UILabel()
//        label.setSectionHeader()
//        return label
//    }()
//
//    private let thirdLabel: UILabel = {
//        let label = UILabel()
//        label.setSectionHeader()
//        return label
//    }()

    private lazy var firstCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    private var dataSource: [[ImageDetail]] = Array(repeating: [], count: 3)

    init(service: APIProtocol) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Topics"
        Task {
            do {
                let result = try await service.getTopic(.init(page: nil, kind: .goldenHour)).get()
//                let result2 = try await service.getTopic(.init(page: nil, kind: .businessWork)).get()
//                let result3 = try await service.getTopic(.init(page: nil, kind: .architectureInterior)).get()

                dataSource[0].append(contentsOf: result)
//                dataSource[1].append(contentsOf: result2)
//                dataSource[2].append(contentsOf: result3)

                firstCollectionView.reloadData()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }

        configureHierarchy()
        configureLayout()
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let screenWidth = view.window?.windowScene?.screen.bounds.width ?? .zero
        let availableWidth = screenWidth - (hInset * 2) - (interSpacing * (itemPerRow - 1))
        let cellWidth = availableWidth / itemPerRow

        let collectionViewHeight = firstCollectionView.bounds.height
        let availableHeight = collectionViewHeight - (vInset * 2) - (lineSpacing * (itemPerCol))
        let cellHeight = availableHeight / itemPerCol
        layout.itemSize = CGSize(
            width: cellWidth,
            height: cellHeight)
        layout.sectionInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
        return layout
    }
}

extension TopicViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource[0].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell() }
        let item = dataSource[0][indexPath.item]
        cell.configure(item)
        return cell
    }
}

extension TopicViewController: BasicViewProtocol {
    func configureHierarchy() {
        view.addSubview(firstLabel)
        view.addSubview(firstCollectionView)
    }

    func configureLayout() {
        firstLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }

        firstCollectionView.snp.makeConstraints { make in
            make.top.equalTo(firstLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(LayoutConstant.topicCollectionViewCellHeight)
        }
    }

    func configureView() {
        firstCollectionView.backgroundColor = .brown
        firstLabel.text = TopicSubject.goldenHour.description

        firstCollectionView.delegate = self
        firstCollectionView.dataSource = self

        firstCollectionView.register(SearchCollectionViewCell.self,
                                     forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.firstCollectionView.collectionViewLayout = self.layout()
        }
    }
}
