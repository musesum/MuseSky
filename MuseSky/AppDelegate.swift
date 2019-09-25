//
//  AppDelegate.swift
//  MuseSky
//
//  Created by warren on 9/22/19.
//  Copyright © 2019 Muse. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.muse.MuseSky.snapshot", using: nil)  { task in
                self.handleSnapshot(task: task as! BGAppRefreshTask)
                
            }
        } 
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        if #available(iOS 13.0, *) {
            scheduleSnapshot()
        }
        else {
            SkyPipeline.shared.saveSnapshot("Snapshot") {
                // not used for iOS 12 task.setTaskCompleted(success: true)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func scheduleSnapshot() {
        let request = BGAppRefreshTaskRequest(identifier: "com.muse.MuseSky.snapshot")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 0)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    /// take a snapshot of current 
    @available(iOS 13.0, *)
    func handleSnapshot(task: BGAppRefreshTask) {


        SkyPipeline.shared.saveSnapshot("Snapshot") {
            task.setTaskCompleted(success: true)
        }
    }


    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

