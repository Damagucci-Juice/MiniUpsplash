//
//  SceneDelegate.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let appWindow = UIWindow(windowScene: windowScene)
        self.window = appWindow

        appCoordinator = AppCoordinator(window: appWindow)
        appCoordinator?.start()
    }
}

