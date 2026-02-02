//
//  TopicViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import UIKit

import SnapKit
import Toast
import Then

final class TopicViewController: UIViewController {

    // MARK: - Data
    private let service: APIProtocol
    private var randomTopics = [TopicSubject]()
    private var dataSource = [[ImageDetail]]()
    private let tableView = UITableView()

    // MARK: - init
    init(service: APIProtocol) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }


    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
        configureLayout()
        configureView()
        refreshTopics()
    }

    private func fetchTopics(_ topics: [TopicSubject]) async {
        var result = [(Int, [ImageDetail])]()
        let group = DispatchGroup()
        for (index, topic) in topics.enumerated() {
            group.enter()
            service.fetch(api: .topic(.init(page: nil, kind: topic)), type: [ImageDetail].self) { response in
                switch response {
                case .success(let success):
                    result.append((index, success))
                case .failure(let failure):
                    self.view.makeToast("""
                            에러코드: \(failure.localizedDescription)
                            \(topic.description) 를 불러오는데 실패했습니다.
                            """)
                }

                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.dataSource = result
                .sorted { $0.0 < $1.0 }
                .map { $0.1 }
            self.tableView.reloadData()
        }
    }

    @objc
    private func refreshTopics() {
        randomTopics = TopicSubject.randomElement(for: 3)
        Task {
            await fetchTopics(randomTopics)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TopicViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TopicTableViewCell.identifier, for: indexPath)
                as? TopicTableViewCell else { return UITableViewCell() }
        let item = dataSource[indexPath.row]

        cell.configureItem(topic: randomTopics[indexPath.row], item) { result in
            print("succee")
        }

        cell.onImageTapped = { image in
            let vc = DetailViewController(imageDetail: image, service: self.service)
            vc.onHaertToggled = {
                cell.toggleHeart(by: image.id)
            }
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }

        
        cell.selectionStyle = .none
        return cell
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerating: Bool) {
        if scrollView.contentOffset.y < -50 {
            refreshTopics()
        }
    }
}

// MARK: - BasicViewProtocol
extension TopicViewController: BasicViewProtocol {
    func configureHierarchy() {
        view.addSubview(tableView)
    }
    
    func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview()
        }
    }
    
    func configureView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(TopicTableViewCell.self, forCellReuseIdentifier: TopicTableViewCell.identifier)
        tableView.rowHeight = LayoutConstant.topicCollectionViewCellHeight
        tableView.separatorStyle = .none
        view.backgroundColor = .white
        navigationItem.title = "Our Topic"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
}
