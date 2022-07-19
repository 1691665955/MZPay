//
//  AppDelegate.swift
//  MZPay
//
//  Created by 曾龙 on 2022/7/18.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        MZPay.registerWechat(appid: "", universalLink: "")
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let result = MZPay.handleOpenURL(url)
        if result {
            return result
        }
        return false
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let result = MZPay.handleOpenUniversalLink(userActivity)
        if result {
            return result
        }
        return false
    }
}

