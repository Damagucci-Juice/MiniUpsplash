//
//  DetailViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/28/26.
//

import UIKit

import Alamofire
import SnapKit

final class DetailViewController: UIViewController {

    private let imageDetail: ImageDetail

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

    private let tempChartView = {
        let result = UIView()
        result.backgroundColor = .cyan
        return result
    }()

    private lazy var posterImageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFit
        result.image = UIImage(systemName: "star.fill")
        result.clipsToBounds = true
        result.backgroundColor = .orange
        return result
    }()

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

        contentView.addSubview(posterImageView)
        contentView.addSubview(tempChartView)
    }

    func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        posterImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(600)
        }

        tempChartView.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(700)
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(300)
        }
    }

    func configureView() {
        navigationItem.title = imageDetail.urls.small
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}
