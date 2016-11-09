//
//  SubscriptionPlan.swift
//  bclub
//
//  Created by Bruno Gama on 09/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

struct SubscriptionPlan {
    enum Recurrence:String {
        case Yearly     = "BCLUB12"
        case Semiannual = "BCLUB6"
        case Monthly    = "BCLUB1"
        case None       = ""
    }
    
    var recurrence:Recurrence = .None
    var price = -1.0
    var gotoAction = ""
    var title = ""
    var summarization = ""
    
    init(recurrence:Recurrence, price:Double, title:String, summarization:String, gotoAction:String) {
        self.recurrence = recurrence
        self.price = price
        self.title = title
        self.summarization = summarization
        self.gotoAction = gotoAction
    }
}