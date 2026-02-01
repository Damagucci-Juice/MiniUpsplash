//
//  SearchViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//

import UIKit

import SnapKit
import Toast
import Then
import Kingfisher

final class SearchResultViewController: UIViewController {

    private lazy var searchBar = UISearchBar().then { tf in
        tf.placeholder = "키워드 검색"
        tf.delegate = self
    }

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

    private let totalCountLabel = UILabel().then { label in
        label.setBody()
        label.text = "20개"
    }

    private var dataSource: [ImageDetail] = []

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

    private func validateSearch() {
        guard let validatedText = validateText(searchBar.text) else { return }
        clearImageCache()
        resetPage(newKey: validatedText)
        Task {
            await requestSearch(makeRequestDto(validatedText, page: page, color: selectedColor, sort: orderBy))
        }
    }

    private func makeRequestDto(_ query: String, page: Int, color: ColorParam?, sort: OrderBy?) -> SearchRequestDTO {
        SearchRequestDTO(
            query: query,
            page: page,
            perPage: countPerPage,
            orderBy: sort,
            color: color)
    }

    private var orderBy = OrderBy.relevant

    // MARK: - Pagination
    private var page = 1
    private let countPerPage = 20
    private var isEnd = false

    private func scrollToTop() {
        guard !dataSource.isEmpty else { return }
        let idxPath = IndexPath(row: 0, section: 0)
        imageCollectionView.scrollToItem(at: idxPath, at: .top, animated: false)
    }

    private func resetPage(newKey: String?) {
        currentSearchKey = newKey
        page = 1
        isEnd = false
        dataSource.removeAll()
        totalCountLabel.isHidden = true
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        clearImageCache()
    }

    func imageLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let hInset = 0.0
        let vInset = 10.0
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

extension SearchResultViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let vc = GoSearchViewController()
        vc.hidesBottomBarWhenPushed = true

        vc.onTextFilled = { text in
            self.searchBar.text = text
            self.searchBarSearchButtonClicked(searchBar)
        }

        vc.onCloseButtonTapped = {
            searchBar.text = nil
            self.searchBarCancelButtonClicked(searchBar)
        }

        if !searchBar.text!.isEmpty {
            vc.searchBarController.searchBar.text = searchBar.text
        }

        navigationController?.pushViewController(vc, animated: true)
    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let validatedText = validateText(searchBar.text) else {
            return
        }
        clearImageCache()
        resetPage(newKey: validatedText)
        handleSearchReturn(validatedText)
    }

    // nil 값이면 벨리데이트 실패, 값이 있다면 제대로 리턴 된 것임
    private func validateText(_ text: String?) -> String? {
        guard let searchText = text,
              !searchText.isEmpty else { return nil }

        let withoutSpacing = searchText.replacingOccurrences(of: " ", with: "")
        if withoutSpacing.count < 2 { return nil }

        return withoutSpacing.lowercased()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetPage(newKey: nil)
        resetCenterLabel()
        clearImageCache()
        imageCollectionView.reloadData()
    }

    private func resetCenterLabel() {
        centerLabel.text = Constant.trySearch
        centerLabel.isHidden = false
    }

    private func handleSearchReturn(_ text: String) {
        Task { [weak self] in
            guard let self else { return }
            await self.requestSearch(makeRequestDto(text, page: self.page, color: self.selectedColor, sort: self.orderBy))
        }
    }

    private func requestSearch(_ dto: SearchRequestDTO) async {
        do {
            let successResponse = try await service.getSearch(dto).get()
            handleSuccess(successResponse)
        } catch {
            debugPrint(error.localizedDescription)
        }

        func handleSuccess(_ response: SearchResponseDTO) {
            if response.results.isEmpty, self.page == 1 {
                // 첫 페이지에서 결과가 비었을 때,
                centerLabel.text = Constant.emptyResult
                centerLabel.isHidden = false
                imageCollectionView.reloadData()
            } else {
                centerLabel.isHidden = true
            }

            // 마지막 페이지 처리
            self.isEnd = response.total_pages < self.page
            guard !isEnd else { return }

            // 결과에 어펜드하고 화면 다시 그리기 후 첫 페이지라면 상단으로 이동
            dataSource.append(contentsOf: response.results)
            imageCollectionView.reloadData()
            if page == 1, !dataSource.isEmpty {
                totalCountLabel.isHidden = false
                totalCountLabel.text = "\(response.total)개"
                scrollToTop()
            }
        }
    }

    private func clearImageCache() {
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
        KingfisherManager.shared.cache.cleanExpiredDiskCache()
    }
}

extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier,
                                                            for: indexPath)
                as? SearchCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(dataSource[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item == dataSource.count - 3, !isEnd, let currentSearchKey else { return }
        page += 1
        handleSearchReturn(currentSearchKey)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // cell tapped
        let item = dataSource[indexPath.item]
        let vc = DetailViewController(imageDetail: item, service: service)
        vc.onHaertToggled = {
            if let cell = collectionView.cellForItem(at: indexPath) as? SearchCollectionViewCell {
                cell.toggleHeart()
            }
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchResultViewController: BasicViewProtocol {
    func configureHierarchy() {
        view.addSubview(colorScrollView)
        colorScrollView.addSubview(colorStackView)
        colorScrollView.addSubview(sortButton)
        view.addSubview(imageCollectionView)
        view.addSubview(centerLabel)
    }

    func configureLayout() {
        colorScrollView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
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
            make.top.equalTo(colorScrollView.snp.bottom).offset(4)
        }

        centerLabel.snp.makeConstraints { make in
            make.center.equalTo(imageCollectionView)
        }
    }

    func configureView() {
        navigationItem.title = "SEARCH PHOTO"
        view.backgroundColor = .white

        configureColorViews()
        imageCollectionView.backgroundColor = .white
        imageCollectionView.register(SearchCollectionViewCell.self,
                                     forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        totalCountLabel.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.imageCollectionView.collectionViewLayout = self.imageLayout()
            self.searchBar.searchTextField.backgroundColor = .systemGray6
            self.configureSearchBar()
        }
    }

    private func configureSearchBar() {
        self.navigationItem.titleView = searchBar
        searchBar.searchTextField.clearButtonMode = .never
    }

    private func configureColorViews() {
        colorScrollView.showsHorizontalScrollIndicator = false

        colorStackView.addArrangedSubview(totalCountLabel)

        ColorParam.allCases.forEach { param in
            let button = ColorFilterButton(colorParam: param)
            button.clipsToBounds = true
            button.onColorButtonTapped = handleColorButtonTapped
            colorStackView.addArrangedSubview(button)
        }
    }

    // MARK: - Color, Sort Option Handlers
    private func handleColorButtonTapped(_ color: ColorParam?) {
        colorStackView.arrangedSubviews.forEach { view in
            guard let colorButton = view as? ColorFilterButton else { return }
            if colorButton.colorParam != color {
                colorButton.isSelected = false
            }
        }
        selectedColor = color

        validateSearch()
    }

    @objc private func orderButtonTapped() {
        sortButton.setTitle(orderBy.text, for: .normal)

        orderBy = orderBy == .relevant ? .latest : .relevant
        validateSearch()
    }

}
