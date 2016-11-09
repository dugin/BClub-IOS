//
//  BorderColorExtension.swift
//  bclub
//
//  Created by Bruno Gama on 03/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import QuartzCore

extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.CGColor
        }
        
        get {
            return UIColor(CGColor: self.borderColor!)
        }
    }
}