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

    private lazy var sortButton = {
        let result = UIButton()
        result.setTitle("최신순", for: .normal)
        return result
    }()

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
              // TODO: - 소문자 처리
              searchText.replacingOccurrences(of: " ", with: "").count > 1 else {
            // TODO: - Alert
            view.makeToast("2글자 이상 입력해주세요")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.becomeFirstResponder()
            }
            return
        }

        let requestDto = SearchRequestDTO(
            query: searchText,
            page: nil,
            perPage: nil,
            orderBy: nil,
            color: nil)

        Task {
            do {
                let successResponse = try await APIService.shared.getSearch(requestDto).get()
                self.datasource.append(contentsOf: successResponse.results)
                self.imageCollectionView.reloadData()
                self.view.makeToast("\(successResponse.results.count)개의 데이터 도착")
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

        cell.contentView.backgroundColor = UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: CGFloat.random(in: 0...1))
        return cell
    }
    

}

extension SearchViewController: BasicViewProtocol {
    func configureHierarchy() {
        view.addSubview(imageCollectionView)
    }
    
    func configureLayout() {
        imageCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constant.colorFilterViewHeight)
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
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.preferredSearchBarPlacement = .stacked
        searchBarController.searchBar.delegate = self
        searchBarController.searchBar.placeholder = "키워드 검색"
        searchBarController.hidesNavigationBarDuringPresentation = false
    }
}
