//
//  AppDelegate.swift
//  bclub
//
//  Created by Bruno Gama on 5/23/16
//  Copyright (c) 2016 bclub. All rights reserved.
//

import UIKit
import SwiftyColor
import Stripe
import KeychainAccess
import Fabric
import Crashlytics
import Google
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var backendless = Backendless.sharedInstance()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        setupFabric()
        registerFirstRunIfNeeded()
        setupBackendless()
        setupGoogleAnalytics()
        setupAppearance()
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        backendless.messaging.registerDeviceToken(deviceToken)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        backendless.messaging.applicationWillTerminate()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        backendless.messaging.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        backendless.messaging.didReceiveRemoteNotification(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        backendless.messaging.didReceiveRemoteNotification(userInfo)
        completionHandler(.NewData)
    }
    
    private func registerFirstRunIfNeeded() {
        var defaults = NSUserDefaults.standardUserDefaults()
        if !defaults.isFirsRunAfterInstall! {
            let keychain = Keychain(service: Constants.KeychainAccess.Service)
            keychain[Constants.KeychainAccess.Service]     = nil
            keychain[Constants.KeychainAccess.UserId]      = nil
            keychain[Constants.KeychainAccess.Email]       = nil
            defaults.isFirsRunAfterInstall = true
        }
    }
    
    private func setupBackendless() {
        backendless.initApp(Constants.Backendless.AppplicationId, secret:Constants.Backendless.IosScretKey, version:Constants.Backendless.Version)
//        backendless.hostURL = "http://api.backendless.com"
        backendless.mediaService = MediaService()

        backendless.messaging.registerForRemoteNotifications()
        
        let persistenceService = backendless.persistenceService
        persistenceService.mapTableToClass(Address.schemaName(), type:Address.ofClass())
        persistenceService.mapTableToClass(City.schemaName(), type:City.ofClass())
        persistenceService.mapTableToClass(Establishment.schemaName(), type:Establishment.ofClass())
        persistenceService.mapTableToClass(EstablishmentCategory.schemaName(), type:EstablishmentCategory.ofClass())
        persistenceService.mapTableToClass(EstablishmentPromotion.schemaName(), type:EstablishmentPromotion.ofClass())
        persistenceService.mapTableToClass(Neighborhood.schemaName(), type:Neighborhood.ofClass())
        persistenceService.mapTableToClass(Promotion.schemaName(), type:Promotion.ofClass())
        persistenceService.mapTableToClass(Telephone.schemaName(), type:Telephone.ofClass())
        persistenceService.mapTableToClass(Voucher.schemaName(), type:Voucher.ofClass())
    }
    
    private func setupAppearance() {
        UINavigationBar.appearance().barTintColor = 0x191919~
        UINavigationBar.appearance().tintColor    = UIColor.whiteColor()
        UINavigationBar.appearance().translucent  = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        UIBarButtonItem.appearance().tintColor    = UIColor.bclRosyPinkColor()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    
    func setupFabric() {
        Fabric.with([Crashlytics.self])
    }
    
    func setupGoogleAnalytics() {
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
    }
}
