//
//  AppDelegate.swift
//  iWod
//
//  Created by WebToGo on 3/28/17.
//  Copyright © 2017 Alvaro GMH. All rights reserved.
//

import UIKit

struct Configuration {
    struct Colors { // Constants for color definitions used in the app
        static let ColorD93636 = UIColor.init(red: 217/255, green: 54/255, blue: 54/255, alpha: 1)
    }
    struct Workout { // Constants for color definitions used in the app
        static let SessionRequest = "https://www.crossfit.com/workout"
        static let StartDayRange = "<h3 class=\"show\"><a href=\"/workout"
        static let StartWodRange = "<div class=\"col-sm-6\">"
        static let EndDayRange = "</div>"
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Customize the navigation and tab bar appearances
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor.white

        // Manage date for updating daily wod
        if UserDefaults.standard.object(forKey: "lastDateWOD") != nil {
            NSLog("[UserDefaults] Log: Found previous date in local DB...")
        } else {
            UserDefaults.standard.set(Date(), forKey: "lastDateWOD")
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

