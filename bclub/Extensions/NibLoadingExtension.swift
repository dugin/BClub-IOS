//
//  NibLoadingExtension.swift
//  bclub
//
//  Created by Marcilio Junior on 24/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

protocol UIViewNibLoading {}
extension UIView : UIViewNibLoading {}

extension UIViewNibLoading where Self : UIView {
    
    static func loadFromNib() -> Self {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiateWithOwner(self, options: nil).first as! Self
    }
    
    static var nibName: String {
        return "\(self)".characters.split{$0 == "."}.map(String.init).last!
    }
    
}