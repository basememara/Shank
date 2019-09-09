//
//  AppDelegate.swift
//  ShankExamples
//
//  Created by Basem Emara on 2019-09-07.
//  Copyright © 2019 Zamzam Inc. All rights reserved.
//

import UIKit
import Shank

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ModuleInject {
    
    let modules: [Module] = [
        AppModule(),
        AppModule(),
        AppModule(),
        AppModule(),
        AppModule()
    ]
}

// MARK: Scene Session

@available(iOS 13.0, *)
extension AppDelegate {

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
