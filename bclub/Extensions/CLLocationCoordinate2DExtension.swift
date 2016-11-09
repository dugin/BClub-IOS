//
//  CLLocationCoordinate2DExtension.swift
//  bclub
//
//  Created by Bruno Gama on 23/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

extension CLLocationCoordinate2D {
    var location:CLLocation? {
        get {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}