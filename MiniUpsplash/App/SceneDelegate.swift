//
//  SceneDelegate.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let service: APIProtocol
        #if DEBUG
        service = MockAPIService.shared
        #else
        service = APIService.shared
        #endif

        let topicNav = UINavigationController(rootViewController: TopicViewController(service: service))
        let searchNav = UINavigationController(rootViewController: SearchViewController(service: service))

        topicNav.tabBarItem = UITabBarItem(title: "토픽", image: UIImage(systemName: "laser.burst"), selectedImage: nil)
        searchNav.tabBarItem = UITabBarItem(title: "검색", image: UIImage(systemName: "sparkle.magnifyingglass"), selectedImage: nil)

        let tab = UITabBarController()
        tab.viewControllers = [topicNav, searchNav]
        self.window?.rootViewController = tab
        self.window?.makeKeyAndVisible()
    }
}

