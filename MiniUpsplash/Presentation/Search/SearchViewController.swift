//
//  SearchViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//

import UIKit

import SnapKit
import Toast

final class SearchViewController: UIViewController {

    private let searchBarController = UISearchController(searchResultsController: nil)

    private let imageCollectionView = UICollectionView(frame: .zero,
                                                       collectionViewLayout: UICollectionViewLayout())
    private var datasource: [ImageDetail] = []

    private let service: APIProtocol

    private lazy var sortButton = {
        let result = UIButton()
        result.setTitle("최신순", for: .normal)
        return result
    }()

    // MARK: - Pagination
    private var page = 1
    private var isEnd = false

    private func scrollToTop() {
        guard !datasource.isEmpty else { return }
        let idxPath = IndexPath(row: 0, section: 0)
        imageCollectionView.scrollToItem(at: idxPath, at: .top, animated: false)
    }

    private func resetPage(newKey: String?) {
        currentSearchKey = newKey
        page = 1
        isEnd = false
        datasource.removeAll()
    }

    private var currentSearchKey: String?

    // MARK: - initialize

    init(service: APIProtocol) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureView()
    }

    func imageLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let hInset = 0.0
        let vInset = 1.0
        let lineSpacing = 2.0
        let interSpacing = 3.0

        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = interSpacing
        let itemPerRow = 2.0
        let itemPerCol = 2.5
        let screenWidth = view.window?.windowScene?.screen.bounds.width ?? .zero
        let availableWidth = screenWidth - (hInset * 2) - (interSpacing * (itemPerRow - 1))
        let cellWidth = availableWidth / itemPerRow

        let collectionViewHeight = imageCollectionView.bounds.height
        let availableHeight = collectionViewHeight - (vInset * 2) - (lineSpacing * (itemPerCol))
        let cellHeight = availableHeight / itemPerCol
        layout.itemSize = CGSize(
            width: cellWidth,
            height: cellHeight)
        layout.sectionInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
        return layout
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text,
              !searchText.isEmpty,
              searchText.replacingOccurrences(of: " ", with: "").count > 1 else {
            view.makeToast("2글자 이상 입력해주세요")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.becomeFirstResponder()
            }
            return
        }
        resetPage(newKey: searchText.lowercased())
        handleSearchReturn(searchText.lowercased())
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetPage(newKey: nil)
        imageCollectionView.reloadData()
    }

    private func handleSearchReturn(_ text: String) {
        // TODO: - param 채우기
        let requestDto = SearchRequestDTO(
            query: text,
            page: page,
            perPage: 30,
            orderBy: nil,
            color: nil)

        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let successResponse = try await service.getSearch(requestDto).get()
                self.isEnd = successResponse.total_pages < self.page
                guard !self.isEnd else { return }

                self.datasource.append(contentsOf: successResponse.results)
                self.imageCollectionView.reloadData()
                if page == 1, !datasource.isEmpty {
                    self.scrollToTop()
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier,
                                                            for: indexPath)
                as? SearchCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(datasource[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item == datasource.count - 3, !isEnd, let currentSearchKey else { return }
        page += 1
        handleSearchReturn(currentSearchKey)
    }
}

extension SearchViewController: BasicViewProtocol {
    func configureHierarchy() {
        view.addSubview(imageCollectionView)
    }
    
    func configureLayout() {
        imageCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(LayoutConstant.colorFilterViewHeight)
        }
    }
    
    func configureView() {
        navigationItem.title = "SEARCH PHOTO"
        view.backgroundColor = .white

        configureSearchController()

        imageCollectionView.backgroundColor = .brown
        imageCollectionView.register(SearchCollectionViewCell.self,
                                     forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.imageCollectionView.collectionViewLayout = self.imageLayout()
        }

    }

    private func configureSearchController() {
        navigationItem.searchController = searchBarController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.preferredSearchBarPlacement = .stacked
        searchBarController.searchBar.delegate = self
        searchBarController.searchBar.placeholder = "키워드 검색"
        searchBarController.hidesNavigationBarDuringPresentation = false
    }
}
