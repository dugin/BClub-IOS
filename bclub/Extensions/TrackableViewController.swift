//
//  TrackedViewController.swift
//  B.Club
//
//  Created by Marcilio Junior on 1/21/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import UIKit
import Google

protocol TrackableViewController {
    
    var screenName: String { get }
    
    func registerScreenView()
    
}

extension TrackableViewController where Self: UIViewController {
    
    var screenName: String {
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
    
    func registerScreenView() {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: screenName)
        
        let screenBuilder = GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject]
        tracker.send(screenBuilder)
    }
}
