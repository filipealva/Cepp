//
//  AppDelegate.swift
//  Cepp
//
//  Created by Filipe Alvarenga on 14/11/14.
//  Copyright (c) 2014 Filipe Alvarenga. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //Configuring Google Analytcs
        MXGoogleAnalytics.ga_inicializeWithTrackingId("UA-52498011-2")
        MXGoogleAnalytics.ga_trackApplicationLauchingWithOptions(launchOptions)
        
        //Setting UIAppearance customized
        self.applyCustomAppearance()
        
        //Start bug tracking with Bugsnag
        Bugsnag.startBugsnagWithApiKey("ffbaf26b2455cd326443fe68f9c8975a")
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: Appearance
    func applyCustomAppearance() -> Void {
        let barTintColor = UIColor(red: 43.0/255, green: 170.0/255, blue: 156.0/255, alpha: 1.0)
        
        UINavigationBar.appearance().barTintColor = barTintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().barStyle = UIBarStyle.BlackTranslucent
    }


}

