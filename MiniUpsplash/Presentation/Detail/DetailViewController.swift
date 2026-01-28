//
//  DetailViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/28/26.
//

import UIKit

import Alamofire
import SnapKit
import Kingfisher
import Then

final class DetailViewController: UIViewController {

    // 데이터소스
    private let imageDetail: ImageDetail

    // 스크롤배경
    private let scrollView = {
        let result = UIScrollView()
        result.showsVerticalScrollIndicator = false
        result.backgroundColor = .darkGray
        return result
    }()

    private let contentView = {
        let result = UIView()
        result.backgroundColor = .lightGray
        return result
    }()

    // User
    private let profileImageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFit
        result.image = UIImage(systemName: "profile.fill")
        result.clipsToBounds = true
        result.setCorner(LayoutConstant.profileImageSize.height/2)
        return result
    }()

    private let userNameLabel = UILabel().then { label in
        label.setBody()
    }

    private let createdAtLabel = UILabel().then { label in
        label.setCaption()
    }

    private lazy var heartButton = UIButton().then { button in
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.setTitleColor(.tintColor, for: .normal)
        button.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
    }

    // main image
    private let posterImageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFit
        result.image = UIImage(systemName: "star.fill")
        result.clipsToBounds = true
        result.backgroundColor = .orange
        return result
    }()

    // data : 정보, 해상도, 조회수, 다운로드
    private let infoLabel = UILabel().then { label in
        label.setHeader()
        label.text = "정보"
    }

    private let sizeHeaderLabel = UILabel().then { label in
        label.setSubHeader()
        label.text = "크기"
    }

    private let sizeBodyLabel = UILabel().then { label in
        label.setBody()
    }

    private let seenHeaderLabel = UILabel().then { label in
        label.setSubHeader()
        label.text = "조회수"
    }

    private let seenBodyLabel = UILabel().then { label in
        label.setBody()

    }

    private let downloadHeaderLabel = UILabel().then { label in
        label.setSubHeader()
        label.text = "다운로드"
    }

    private let downloadBodyLabel = UILabel().then { label in
        label.setBody()
    }

    // TODO: - 차트 영역
    private let tempChartView = {
        let result = UIView()
        result.backgroundColor = .cyan
        return result
    }()

    @objc private func heartButtonTapped() {
        print(#function)
    }

    init(imageDetail: ImageDetail) {
        self.imageDetail = imageDetail
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension DetailViewController: BasicViewProtocol {
    func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // user
        [profileImageView, userNameLabel, createdAtLabel, heartButton].forEach {
            contentView.addSubview($0)
        }

        // main image
        contentView.addSubview(posterImageView)

        // data
        [infoLabel, sizeHeaderLabel, sizeBodyLabel,
         seenHeaderLabel, seenBodyLabel, downloadHeaderLabel, downloadBodyLabel].forEach {
            contentView.addSubview($0)
        }

        // chart
        contentView.addSubview(tempChartView)
    }

    func configureLayout() {
        // background
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        // user
        profileImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
            make.size.equalTo(LayoutConstant.profileImageSize)
        }

        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(4)
            make.top.equalTo(profileImageView)
        }

        createdAtLabel.snp.makeConstraints { make in
            make.leading.equalTo(userNameLabel)
            make.bottom.equalTo(profileImageView)
        }

        heartButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(profileImageView)
            make.size.equalTo(LayoutConstant.profileImageSize)
        }

        // main image
        posterImageView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            // TODO: - image height 동적으로 조정
//            make.height.equalTo(300)
        }

        // data
        infoLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView)
            make.top.equalTo(posterImageView.snp.bottom).offset(24)
        }

        // header
        sizeHeaderLabel.snp.makeConstraints { make in
            make.centerY.equalTo(infoLabel)
            make.leading.equalTo(infoLabel.snp.trailing).offset(64)
        }

        seenHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(sizeHeaderLabel.snp.bottom).offset(16)
            make.leading.equalTo(sizeHeaderLabel)
        }

        downloadHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(seenHeaderLabel.snp.bottom).offset(16)
            make.leading.equalTo(seenHeaderLabel)
        }

        // body
        sizeBodyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(sizeHeaderLabel)
            make.trailing.equalToSuperview().inset(16)
        }

        seenBodyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(seenHeaderLabel)
            make.trailing.equalToSuperview().inset(16)
        }

        downloadBodyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(downloadHeaderLabel)
            make.trailing.equalToSuperview().inset(16)
        }

        // TODO: - 차트 나중에 바꿔야함
        tempChartView.snp.makeConstraints { make in
            make.top.equalTo(downloadHeaderLabel.snp.bottom).offset(100)
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(300)
        }
    }

    func configureView() {
        navigationController?.navigationBar.prefersLargeTitles = false

        profileImageView.kf.setImage(
            with: URL(string: imageDetail.user.profileImage.medium)
        )

        userNameLabel.text = imageDetail.user.username
        createdAtLabel.text = imageDetail.createdAt

        setupPosterImageView()

        sizeBodyLabel.text = "\(imageDetail.width) x \(imageDetail.height)"
        seenBodyLabel.text = NumberManager.shared.convert(1_548_623)
        downloadBodyLabel.text = NumberManager.shared.convert(388_996)
    }

    private func setupPosterImageView() {
        let deviceScale = UIScreen.main.scale
        let optimizedScale: CGFloat = min(2.0, deviceScale)

        let screenWidth = UIScreen.main.bounds.width
        let screenImageWidthRatio = CGFloat(imageDetail.width) / screenWidth
        let targetSize = CGSize(width: screenWidth, height: CGFloat(imageDetail.height) / screenImageWidthRatio)
        let processor = DownsamplingImageProcessor(size: targetSize)

        posterImageView.kf.setImage(
            with: URL(string: imageDetail.urls.raw),
            options: [
                .processor(processor),
                .scaleFactor(optimizedScale),
                .cacheSerializer(FormatIndicatedCacheSerializer.jpeg),
                .transition(.fade(0.2))
            ]
        )
    }
}
