//
//  AppDelegate.swift
//  SwitchboardExample
//
//  Created by Rob Phillips on 10/3/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import UIKit
import Switchboard

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupRootView()
        setupAppearances()
        activateSwitchboard()

        return true
    }

}

// MARK: - Private API

fileprivate extension AppDelegate {

    func setupRootView() {
        let navVC = UINavigationController(rootViewController: MainViewController())
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }

    func setupAppearances() {
        let color = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        UIButton.appearance().setTitleColor(color, for: .normal)
    }

    func activateSwitchboard() {
//        // You can clear cache using
//        SwitchboardCache.clear()
//        // Debug has its own cache
//        SwitchboardDebugController(switchboard: ExampleSwitchboard.shared).clearCacheAndSwitchboard()

        ExampleSwitchboard.shared.activate(serverUrlString: ExampleSwitchboard.serverUrlString) { error in
            if let error = error {
                print("Error fetching experiments & features (but we might still have cached values): \(error.localizedDescription)")
            } else {
                print("[SWITCHBOARD] Debugging? \(ExampleSwitchboard.shared.isDebugging)")
                print("[SWITCHBOARD] Experiments: \(ExampleSwitchboard.shared.experiments)")
                print("[SWITCHBOARD] Features: \(ExampleSwitchboard.shared.features)")
            }
        }
    }

}

