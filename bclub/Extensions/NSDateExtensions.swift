//
//  NSDateExtensions.swift
//  bclub
//
//  Created by Bruno Gama on 14/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

extension NSDate {
    
    private enum Timescale {
        static let minute = 60.0
        static let hour   = Timescale.minute * 60
        static let day    = Timescale.hour   * 24
        static let year   = Timescale.day    * 365
    }
    
    func dateByAddingMinutes(minutes:Double) -> NSDate {
        return dateByAddingTimeInterval(Timescale.minute * minutes)
    }
    
    func dateByAddingHours(hours:Double) -> NSDate {
        return dateByAddingTimeInterval(Timescale.hour   * hours)
    }
    
    func dateByAddingDays(days:Double) -> NSDate {
        return dateByAddingTimeInterval(Timescale.day    * days)
    }
    
    func dateByAddingYears(years:Double) -> NSDate {
        return dateByAddingTimeInterval(Timescale.year   * years)
    }

    var januaryFirst: NSDate? {
        let components = NSCalendar.currentCalendar().components(.Year, fromDate: self)
        components.day = 1
        components.month = 1
        return NSCalendar.currentCalendar().dateFromComponents(components)
    }
}