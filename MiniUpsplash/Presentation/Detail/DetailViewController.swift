//
//  DetailViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/28/26.
//

import UIKit

class DetailViewController: UIViewController {

    let imageDetail: ImageDetail

    init(imageDetail: ImageDetail) {
        self.imageDetail = imageDetail
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = imageDetail.urls.small
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

