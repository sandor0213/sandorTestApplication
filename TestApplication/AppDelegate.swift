//
//  AppDelegate.swift
//  TestApplication
//
//  Created by AzinecLLC on 3/21/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
let currentUser = UserDefaults.standard


    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

      
              UIDevice.current.isBatteryMonitoringEnabled = true   
       
        // Observe battery state
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.alertBatteryStateDidChange),
                                               name: NSNotification.Name.UIDeviceBatteryStateDidChange,
                                               object: nil)
    
              
           //**device token
        // iOS 10 support
        if #available(iOS 10, *) {  
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {  
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {  
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {  
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
           //**device token
        
       return true
    
    }
    

    
    
    func alertBatteryStateDidChange() {
        let status = UIDevice.current.batteryState
 
        if currentUser.bool(forKey: "sendedRequest"){
        
        if status == .charging && HelperMyLocationDistance().distanceFromUserLocationToSpot() {
            self.currentUser.set(true, forKey: "startedChargeInSelectedSpot")
            ShowAlertForAppDelegateNSObject().showAlert(text: "You started charge your device at \(self.currentUser.string(forKey: "spotName")!)", controller: UIApplication.topViewController()!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startCharge"), object: nil)
        }
                
        if status == .unplugged && HelperMyLocationDistance().distanceFromUserLocationToSpot() && self.currentUser.bool(forKey: "startedChargeInSelectedSpot") {
            self.currentUser.set(false, forKey: "startedChargeInSelectedSpot")
           
            ShowAlertForAppDelegateNSObject().showAlert(text: "You had finish charge your device at \(self.currentUser.string(forKey: "spotName")!)", controller: UIApplication.topViewController()!)
            
   
            
            HelperAlamofires().putCanceledPrivateHostRequestBeforeConfirmation(userId: currentUser.string(forKey: "userid")!, historyId: self.currentUser.string(forKey: "historyIdWhenSendRequestForAplug")!) { (status, json) in
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            
                
                
                
                
                
            }   
            
        }
        
        }
    }
        
    
    

    
  

    
    

    //**device token
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {  
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        currentUser.set(deviceTokenString, forKey: "deviceToken")  
    }
    //**device token
    
    
    

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


