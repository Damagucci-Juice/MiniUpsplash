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

    private let colorScrollView = UIScrollView()
    private let colorStackView = {
        let result = UIStackView()
        result.axis = .horizontal
        result.spacing = 10
        result.distribution = .fillProportionally
        result.alignment = .fill
        result.backgroundColor = .white
        return result
    }()

    private let centerLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.trySearch
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private var datasource: [ImageDetail] = []

    private let service: APIProtocol

    private var selectedColor: ColorParam?

    private lazy var sortButton = {
        let result = UIButton()
        result.setTitle(OrderBy.relevant.text, for: .normal)
        result.setImage(UIImage(systemName: "text.line.2.summary"), for: .normal)
        result.setTitleColor(.black, for: .normal)
        result.backgroundColor = .white
        result.tintColor = .black
        result.addTarget(self, action: #selector(orderButtonTapped), for: .touchUpInside)
        result.setCorner(LayoutConstant.colorFilterViewHeight / 2)
        result.setBorder(1.0, color: .black)
        return result
    }()

    @objc private func orderButtonTapped() {
        orderBy = orderBy == .relevant ? .latest : .relevant
        sortButton.setTitle(orderBy.text, for: .normal)
        // TODO: - 컬러와 마찬가지로 선택 값이 바뀔 때 페이지네이션 어떻게 할지 충분한 고민이 필요해 보임...
        /// 어떻게 해야 말이 되는 Pagination을 구현할 수 있을까 ?
    }

    private var orderBy = OrderBy.relevant

    // MARK: - Pagination
    private var page = 1
    private let countPerPage = 20
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
        resetCenterLabel()
        imageCollectionView.reloadData()
    }

    private func resetCenterLabel() {
        centerLabel.text = Constant.trySearch
        centerLabel.isHidden = false
    }

    private func handleSearchReturn(_ text: String) {
        let requestDto = SearchRequestDTO(
            query: text,
            page: page,
            perPage: countPerPage,
            orderBy: orderBy,
            color: selectedColor)

        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let successResponse = try await service.getSearch(requestDto).get()
                if successResponse.results.isEmpty, self.page == 1 {
                    centerLabel.text = Constant.emptyResult
                    centerLabel.isHidden = false
                    self.imageCollectionView.reloadData()
                } else {
                    centerLabel.isHidden = true
                }

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
        view.addSubview(colorScrollView)
        colorScrollView.addSubview(colorStackView)
        colorScrollView.addSubview(sortButton)
        view.addSubview(imageCollectionView)
        view.addSubview(centerLabel)
    }
    
    func configureLayout() {
        colorScrollView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(LayoutConstant.colorFilterViewHeight)
        }

        sortButton.snp.makeConstraints { make in
            make.height.equalTo(colorScrollView.frameLayoutGuide)
            make.width.greaterThanOrEqualTo(LayoutConstant.orderByButtonWidth)
            make.verticalEdges.trailing.equalTo(colorScrollView.frameLayoutGuide)
        }

        colorStackView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(colorScrollView.contentLayoutGuide)
            make.trailing.equalTo(colorScrollView.contentLayoutGuide).inset(LayoutConstant.orderByButtonWidth)
            make.leading.equalTo(colorScrollView.contentLayoutGuide).offset(16)
            make.height.equalTo(colorScrollView.frameLayoutGuide)
        }

        imageCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(LayoutConstant.colorFilterViewHeight)
        }

        centerLabel.snp.makeConstraints { make in
            make.center.equalTo(imageCollectionView)
        }
    }
    
    func configureView() {
        navigationItem.title = "SEARCH PHOTO"
        view.backgroundColor = .white

        configureColorViews()
        configureSearchController()

        imageCollectionView.backgroundColor = .white
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

    private func configureColorViews() {
        colorScrollView.showsHorizontalScrollIndicator = false

        // TODO: - Color Select
        ColorParam.allCases.forEach { param in
            let button = ColorFilterButton(colorParam: param)
            button.clipsToBounds = true
            button.onColorButtonTapped = handleColorButtonTapped
            colorStackView.addArrangedSubview(button)
        }
    }

    private func handleColorButtonTapped(_ color: ColorParam) {
        colorStackView.arrangedSubviews.forEach { view in
            guard let colorButton = view as? ColorFilterButton else { return }
            if colorButton.colorParam != color {
                colorButton.isSelected = false
            }
        }

        if selectedColor == nil {
            page = 1
            selectedColor = color
        } else if selectedColor != nil {
            if selectedColor == color { //
                selectedColor = nil
            } else {
                selectedColor = color
            }
            page = 1
        }

        // TODO: - Page 전환은 어떻게 할건가? 이미 요청이 간 상태에서 버튼을 바꾸면 페이지 리셋?
        /// 한다면 여기서 해야하나?
        /// 1. 위의 코드의 문제점은 컬러를 그냥 토글만 했을 때는, 이전 페이지 기록이 사라지는 문제가 있음
        /// 2. 만약에 컬러를 버튼을 눌렀고 검색을 시작했을 때, 중간에 색을 바꿨어... 그러면 그러면 다른 색으로 페이지네이션이 될 건데
        /// 2-1 red,1 -> red,2 -> green 1 이 되서 총 90장이 보일 것임
        ///
    }
}
