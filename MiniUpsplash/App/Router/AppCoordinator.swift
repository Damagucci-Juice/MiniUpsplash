//
//  AppCoordinator.swift
//  MiniUpsplash
//
//  Created by Gucci on 2/3/26.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private var window: UIWindow
    private var tabBarController: UITabBarController

    init(window: UIWindow) {
        self.window = window
        self.tabBarController = UITabBarController()
    }

    static var service: APIProtocol {
        let service: APIProtocol
        #if DEBUG
        service = MockAPIService.shared
        #else
        service = APIService.shared
        #endif
        return service
    }

    func start() {
        let topicNav = UINavigationController()
        let searchNav = UINavigationController()
        let topicCoordinator = TopicCoordinator(navigationController: topicNav)
        let searchCoordinator = SearchCoordinator(navigationController: searchNav)

        childCoordinators = [topicCoordinator, searchCoordinator]
        childCoordinators.forEach { $0.start() }

        tabBarController.viewControllers = [topicNav, searchNav]
        self.window.rootViewController = tabBarController
        self.window.makeKeyAndVisible()
    }


}
