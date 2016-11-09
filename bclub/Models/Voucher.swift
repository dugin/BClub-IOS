//
//  Voucher.swift
//  bclub
//
//  Created by Bruno Gama on 15/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

class Voucher: BackendlessEntity {
    var name:String     = ""
    var email:String    = ""
    var used:Bool        = false
    
    private override init() {
    }
    init(name:String, email:String, used:Bool) {
        self.name = name
        self.email = email
        self.used = used
    }
}