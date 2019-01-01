//
//  AppDelegate.swift
//  Blur
//
//  Created by Xavi Moll on 01/01/2019.
//  Copyright © 2019 xmollv. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let mainViewController = MainViewController()
        let navigationController = NavigationController(rootViewController: mainViewController)
        
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()
        
        return true
    }

}

