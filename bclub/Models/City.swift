//
//  City.swift
//  bclub
//
//  Created by Bruno Gama on 25/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

class City:BackendlessEntity {
    var name:String?
    
    func save() {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.defaultCity = name!
        defaults.defaultCityId = objectId
    }
}