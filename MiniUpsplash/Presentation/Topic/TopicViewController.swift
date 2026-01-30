//
//  TopicViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import UIKit

import SnapKit

final class TopicViewController: UIViewController {

    // Data
    private let service: APIProtocol
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var randomTopics = [TopicSubject]()
    private var dataSource = [[ImageDetail]]()


    // UI
    private let firstLabel: UILabel = {
        let label = UILabel()
        label.setSectionHeader()
        return label
    }()
    
    private let secondLabel: UILabel = {
        let label = UILabel()
        label.setSectionHeader()
        return label
    }()
    
    private let thirdLabel: UILabel = {
        let label = UILabel()
        label.setSectionHeader()
        return label
    }()

    private lazy var firstCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private lazy var secondCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private lazy var thirdCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    // init
    init(service: APIProtocol) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }


    // life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
        configureLayout()
        configureView()
    }

    private func fetchTopics() async throws -> [[ImageDetail]] {
        do {
            // TODO: - 만약에 랜덤 20개를 해달라고 하면 20줄 추가할꺼야? 어떻게 할래?
            async let result  = service.getTopic(.init(page: nil, kind: randomTopics[0])).get()
            async let result2 = service.getTopic(.init(page: nil, kind: randomTopics[1])).get()
            async let result3 = service.getTopic(.init(page: nil, kind: randomTopics[2])).get()

            return try await [result, result2, result3]
        } catch {
            throw error
        }
    }

    private func tableviewsReload() {
        firstCollectionView.reloadData()
        secondCollectionView.reloadData()
        thirdCollectionView.reloadData()
    }

    private func refreshTopics() {
        randomTopics = TopicSubject.randomElement(for: 3)
        Task {
            if let datasource = try? await fetchTopics() {
                self.dataSource = datasource
                tableviewsReload()
            }
        }
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

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TopicViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.isEmpty ? 0 : dataSource[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell() }
        let item = dataSource[collectionView.tag][indexPath.item]
        cell.configure(item)
        cell.setCorner(16)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // cell tapped
        let item = dataSource[collectionView.tag][indexPath.row]
        let vc = DetailViewController(imageDetail: item, service: service)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - BasicViewProtocol
extension TopicViewController: BasicViewProtocol {
    func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(firstLabel)
        contentView.addSubview(firstCollectionView)
        
        contentView.addSubview(secondLabel)
        contentView.addSubview(secondCollectionView)
        
        contentView.addSubview(thirdLabel)
        contentView.addSubview(thirdCollectionView)
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        firstLabel.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(contentView).inset(16)
        }
        
        firstCollectionView.snp.makeConstraints { make in
            make.top.equalTo(firstLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(contentView)
            make.height.equalTo(LayoutConstant.topicCollectionViewCellHeight)
        }
        
        secondLabel.snp.makeConstraints { make in
            make.leading.equalTo(firstLabel)
            make.top.equalTo(firstCollectionView.snp.bottom).offset(32)
        }
        
        secondCollectionView.snp.makeConstraints { make in
            make.top.equalTo(secondLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(contentView)
            make.height.equalTo(LayoutConstant.topicCollectionViewCellHeight)
        }
        
        thirdLabel.snp.makeConstraints { make in
            make.leading.equalTo(firstLabel)
            make.top.equalTo(secondCollectionView.snp.bottom).offset(32)
        }
        
        thirdCollectionView.snp.makeConstraints { make in
            make.top.equalTo(thirdLabel.snp.bottom).offset(16)
            make.horizontalEdges.bottom.equalTo(contentView)
            make.height.equalTo(LayoutConstant.topicCollectionViewCellHeight)
        }
        
    }
    
    func configureView() {
        refreshTopics()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        view.backgroundColor = .white
        navigationItem.title = "Our Topic"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        guard !randomTopics.isEmpty else { return }
        configureCollectionSection(label: firstLabel, collectionView: firstCollectionView, subject: randomTopics[0])
        configureCollectionSection(label: secondLabel, collectionView: secondCollectionView, subject: randomTopics[1])
        configureCollectionSection(label: thirdLabel, collectionView: thirdCollectionView, subject: randomTopics[2])
        firstCollectionView.tag = 0
        secondCollectionView.tag = 1
        thirdCollectionView.tag = 2
    }
    
    func configureCollectionSection(label: UILabel, collectionView: UICollectionView, subject: TopicSubject) {
        label.text = subject.description
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
