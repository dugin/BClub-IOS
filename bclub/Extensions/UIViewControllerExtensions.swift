//
//  UIViewControllerExtensions.swift
//  bclub
//
//  Created by Bruno Gama on 14/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import MRProgress
import SwiftyColor

protocol UIViewControllerExtensions {}

protocol FetchableContentProtocol {}

extension FetchableContentProtocol where Self : UIViewController {

    func presentLoadingViewWithTitle(title:String?) {
        
        let progress = MRProgressOverlayView()
        self.view.addSubview(progress)
        progress.show(true)
        progress.setTintColor(Color.bclRosyPinkColor())
        if let t = title {
            progress.titleLabelText = t
        } else {
            progress.titleLabelText = ""
        }
        
        progress.tag = 29399
    }
    
    func presentLoadingView() {
        presentLoadingViewWithTitle(nil)
    }
    
    func dismissLoadingView() {
        let progress = self.view.viewWithTag(29399) as! MRProgressOverlayView
        progress.show(false)
        progress.removeFromSuperview()
    }
}