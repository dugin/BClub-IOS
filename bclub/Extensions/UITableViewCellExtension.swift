//
//  UITableViewCellExtension.swift
//  bclub
//
//  Created by Bruno Gama on 25/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

protocol UITableViewCellExtension {}

extension UITableViewCell : UITableViewCellExtension {}

extension UITableViewCellExtension where Self : UITableViewCell {
    static func cellName() -> String {
        return "\(self)"
    }
    
    static var identifier: String {
        return "\(self)"
    }
}