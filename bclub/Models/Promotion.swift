//
//  Promotion.swift
//  bclub
//
//  Created by Bruno Gama on 25/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

class Promotion:BackendlessEntity {
    var percent:NSNumber = 0.0
    var monday = ""
    var tuesday = ""
    var wednesday = ""
    var thursday = ""
    var friday = ""
    var saturday = ""
    var sunday = ""
    
    override var description: String {
        get {
            return "Promotion[percent=\(percent), monday=\(monday), tuesday=\(tuesday), wednesday=\(wednesday), thursday=\(thursday), friday=\(friday), saturday=\(saturday), sunday=\(sunday)]"
        }
    }
}