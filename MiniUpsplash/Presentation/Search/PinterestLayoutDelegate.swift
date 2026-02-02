//
//  PinterestLayoutDelegate.swift
//  MiniUpsplash
//
//  Created by Gucci on 2/2/26.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewFlowLayout {

    let numberOfColumns: Int
    let padding: CGFloat

    init(numberOfColumns: Int, padding: CGFloat) {
        self.numberOfColumns = numberOfColumns
        self.padding = padding
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        guard let collectionView = collectionView else { return }
        cache.removeAll()
        contentHeight = 0

        // 1. 기본 설정 변경
        let numberOfColumns: Int = numberOfColumns // 3열로 변경
        let cellPadding: CGFloat = padding // 패딩 2로 변경
        let cellWidth: CGFloat = contentWidth / CGFloat(numberOfColumns)

        // 2. xOffset 동적 생성
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * cellWidth)
        }

        // 3. yOffset 초기화 (numberOfColumns 크기만큼 0으로 채움)
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)

        var column: Int = 0

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            // Delegate로부터 높이 계산 (여기에 패딩이 포함되지 않도록 주의)
            let photoHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath) ?? 180
            let height = cellPadding * 2 + photoHeight

            let frame = CGRect(x: xOffset[column],
                               y: yOffset[column],
                               width: cellWidth,
                               height: height)

            // 실제 셀의 프레임에 패딩 적용
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            // 가장 높이가 낮은 열(column)을 찾아 다음 아이템 배치
            column = yOffset.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
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
