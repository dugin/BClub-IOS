//
//  NSUserDefaultsExtension.swift
//  bclub
//
//  Created by Bruno Gama on 20/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

enum DefaultKey : String {
    case FirstRunAfterInstall = "UserDefaults.FirstRun"
    case DefaultCity          = "UserDefaults.CityKey"
    case DefaultCityId        = "UserDefaults.CityIdKey"
    case TutorialWasShowed    = "UserDefaults.TutorialShowedKey"
}
protocol AppDefaults {}

extension NSUserDefaults : AppDefaults {}

extension AppDefaults where Self: NSUserDefaults {
    
    var isFirsRunAfterInstall:Bool? {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(DefaultKey.FirstRunAfterInstall.rawValue)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue!, forKey: DefaultKey.FirstRunAfterInstall.rawValue)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var defaultCity:String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(DefaultKey.DefaultCity.rawValue)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue!, forKey: DefaultKey.DefaultCity.rawValue)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var defaultCityId:String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(DefaultKey.DefaultCityId.rawValue)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue!, forKey: DefaultKey.DefaultCityId.rawValue)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var tutorialWasPresented:Bool? {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(DefaultKey.TutorialWasShowed.rawValue)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue!, forKey: DefaultKey.TutorialWasShowed.rawValue)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}