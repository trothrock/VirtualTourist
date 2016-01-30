//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/20/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func applicationWillResignActive(application: UIApplication) {}

    func applicationDidEnterBackground(application: UIApplication) {
        CoreDataStackManager.sharedInstance().saveContext {_ in}
    }

    func applicationWillEnterForeground(application: UIApplication) {}

    func applicationDidBecomeActive(application: UIApplication) {}

    func applicationWillTerminate(application: UIApplication) {
        CoreDataStackManager.sharedInstance().saveContext {_ in}
    }
}

