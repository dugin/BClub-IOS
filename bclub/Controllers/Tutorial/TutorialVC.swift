//
//  TutorialVC.swift
//  bclub
//
//  Created by Douglas on 07/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import UIKit
import SwiftyColor

class TutorialVC: UIViewController {
    
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var joinedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinedButton.setBackgroundImage(UIImage(color: Color.bclRosyPinkColor()), forState: .Normal)
        joinedButton.setTitleColor(Color.white, forState: .Normal)

        enterButton.setBackgroundImage(UIImage(color: Color.clearColor()), forState: .Normal)
        enterButton.setTitleColor(Color.bclRosyPinkColor(), forState: .Normal)
        enterButton.layer.borderColor = UIColor.whiteColor().CGColor;
        enterButton.layer.borderWidth = 2.0;
    }
    
    @IBAction func clickJoined(sender: AnyObject) {
        
        let navController = presentingViewController as! UINavigationController
        let promotionListVC = navController.viewControllers[0] as! PromotionListVC
        dismissViewControllerAnimated(true) {
            promotionListVC.testAssinar();
            promotionListVC.goFromSplash = true;
        }
        
        
    }
    @IBAction func clickEnter(sender: AnyObject) {

        let navController = presentingViewController as! UINavigationController
        let promotionListVC = navController.viewControllers[0] as! PromotionListVC
        
        dismissViewControllerAnimated(true) {
            promotionListVC.splashWasShowed = false
            promotionListVC.startCustomLoading()
            promotionListVC.locationManager = LocationManager()
            promotionListVC.setupLocationManager()
            promotionListVC.locationManager.requestUserLocation()
        }

    }
    
    func responseHandler(response: AnyObject!) -> AnyObject {
        
        let messages = response as! [Message]
        for message in messages {
            var publisher = message.headers["publisher_name"]
            if publisher == nil {
                publisher = "Anonymous"
            }
            print("\(publisher) -> \(message.data)")
        }
        return response
    }
    
    func errorHandler(fault: Fault!) {
        print("FAULT: \(fault)")
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
