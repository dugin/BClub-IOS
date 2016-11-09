//
//  UITextFieldExtension.swift
//  bclub
//
//  Created by Bruno Gama on 13/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

extension UITextField {
    class func connectFields(fields:[UITextField]) -> Void {
        guard let last = fields.last else {
            return
        }
        for i in 0 ..< fields.count - 1 {
            fields[i].returnKeyType = .Next
            fields[i].addTarget(fields[i+1], action: #selector(becomeFirstResponder), forControlEvents: .EditingDidEndOnExit)
        }
        last.returnKeyType = .Done
        last.addTarget(last, action: #selector(resignFirstResponder), forControlEvents: .EditingDidEndOnExit)
    }
}