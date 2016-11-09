//
//  Address.swift
//  bclub
//
//  Created by Bruno Gama on 24/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

class Address:BackendlessEntity {
    var complement = ""
    var number = ""
    var street = ""
    var neighborhood:Neighborhood?
    var geolocation:GeoPoint?
    
    override var description: String {
        get {
            var address = "\(street) \(number) "
            if !complement.isBlank {
                address += ", \(complement)"
            }
            
            guard let n = neighborhood?.name else {
                return address
            }
            
            address += " - \(n)"
            return address
        }
    }
}
