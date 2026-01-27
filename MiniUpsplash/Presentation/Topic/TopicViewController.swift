//
//  TopicViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import UIKit

final class TopicViewController: UIViewController {

    private let service: APIProtocol

    init(service: APIProtocol) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Topics"
        Task {
            do {
                let result = try await service.getTopic(.init(page: nil, kind: .goldenHour))
                print(result)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
