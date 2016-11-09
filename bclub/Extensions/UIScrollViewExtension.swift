//
//  UIScrollViewExtension.swift
//  bclub
//
//  Created by Bruno Gama on 30/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}