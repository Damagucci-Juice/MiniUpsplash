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

    private let hInset = 0.0
    private let vInset = 10.0
    private let lineSpacing = 2.0
    private let interSpacing = 3.0
    private let itemPerRow = 3.0
    private let itemPerCol = 2.5
    private lazy var screenWidth = view.window?.windowScene?.screen.bounds.width ?? .zero

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBarSearchButtonClicked(searchBar)
    }
}

extension SearchResultViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let vc = GoSearchViewController()
        vc.hidesBottomBarWhenPushed = true

        vc.onTextFilled = { text in
            self.searchBar.text = text
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
            let successResponse: SearchResponseDTO = try await service.fetch(api: .search(dto)).get()
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

extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PinterestLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let cellWidth: CGFloat = (view.bounds.width - 4) / 2 // 셀 가로 크기
        let item = dataSource[indexPath.item]
        let imageRatio: Double = Double(item.height) / Double(item.width) // 이미지 비율

        return CGFloat(imageRatio) * cellWidth
    }

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
            let pinterestLayout = PinterestLayout()
            pinterestLayout.delegate = self
            self.imageCollectionView.collectionViewLayout = pinterestLayout
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

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewFlowLayout {

    // delegate로 ViewController 를 나타낸다.
    weak var delegate: PinterestLayoutDelegate?

    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    // 1. 콜렉션 뷰의 콘텐츠 사이즈를 지정합니다.
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    private var cache: [UICollectionViewLayoutAttributes] = []

    // 2. 콜렉션 뷰가 처음 초기화되거나 뷰가 변경될 떄 실행됩니다. 이 메서드에서 레이아웃을
    //    미리 계산하여 메모리에 적재하고, 필요할 때마다 효율적으로 접근할 수 있도록 구현해야 합니다.
    override func prepare() {
        guard let collectionView = collectionView, cache.isEmpty else { return }

        let numberOfColumns: Int = 2 // 한 행의 아이템 갯수
        let cellPadding: CGFloat = 2
        let cellWidth: CGFloat = contentWidth / CGFloat(numberOfColumns)

        let xOffSet: [CGFloat] = [0, cellWidth] // cell 의 x 위치를 나타내는 배열
        var yOffSet: [CGFloat] = .init(repeating: 0, count: numberOfColumns) // // cell 의 y 위치를 나타내는 배열

        var column: Int = 0 // 현재 행의 위치

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            // IndexPath 에 맞는 셀의 크기, 위치를 계산합니다.
            let indexPath = IndexPath(item: item, section: 0)
            let imageHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath) ?? 180
            let height = cellPadding * 2 + imageHeight

            let frame = CGRect(x: xOffSet[column],
                               y: yOffSet[column],
                               width: cellWidth,
                               height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            // 위에서 계산한 Frame 을 기반으로 cache 에 들어갈 레이아웃 정보를 추가합니다.
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            // 콜렉션 뷰의 contentHeight 를 다시 지정합니다.
            contentHeight = max(contentHeight, frame.maxY)
            yOffSet[column] = yOffSet[column] + height

            // 다른 이미지 크기로 인해서, 한쪽 열에만 이미지가 추가되는 것을 방지합니다.
            column = yOffSet[0] > yOffSet[1] ? 1 : 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

        for attributes in cache {
            if attributes.frame.intersects(rect) { // 셀 frame 과 요청 Rect 가 교차한다면, 리턴 값에 추가합니다.
                visibleLayoutAttributes.append(attributes)
            }
        }

        return visibleLayoutAttributes
    }

    // 4. 모든 셀의 레이아웃 정보를 리턴합니다. IndexPath 로 요청이 들어올 때 이 메서드를 사용합니다.
    override func layoutAttributesForItem(at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
