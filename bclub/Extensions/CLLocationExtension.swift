//
//  CLLocationExtension.swift
//  bclub
//
//  Created by Bruno Gama on 03/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import CoreLocation

protocol CLLocationExtension {}

extension CLLocation {
    func distanceFromGeoPoint(geoPoint:GeoPoint) -> Double {
        let toLocation = CLLocation(latitude: geoPoint.latitude.doubleValue,
                                    longitude: geoPoint.longitude.doubleValue)

        let distanceMeters = self.distanceFromLocation(toLocation)
        let distanceKM = distanceMeters / 1000
        return Double(round(100*distanceKM)/100)
    }
    
    func formattedDistanceFromGeoPoint(geoPoint: GeoPoint) -> String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.decimalSeparator = ","
        numberFormatter.groupingSeparator = "."
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        
        let distance = distanceFromGeoPoint(geoPoint)
        
        if let formattedDistance = numberFormatter.stringFromNumber(distance) {
            return formattedDistance
        }
        
        return ""
    }
}