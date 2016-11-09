//
//  TimeExtensions.swift
//  B.Club
//
//  Created by Marcilio Junior on 2/19/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

extension Int {
    
    var second:  dispatch_time_t { return dispatch_time(DISPATCH_TIME_NOW, (Int64)(UInt64(self) * NSEC_PER_SEC)) }
    var seconds: dispatch_time_t { return dispatch_time(DISPATCH_TIME_NOW, (Int64)(UInt64(self) * NSEC_PER_SEC)) }
    var minute:  dispatch_time_t { return dispatch_time(DISPATCH_TIME_NOW, (Int64)(UInt64(self * 60) * NSEC_PER_SEC)) }
    var minutes: dispatch_time_t { return dispatch_time(DISPATCH_TIME_NOW, (Int64)(UInt64(self * 60) * NSEC_PER_SEC)) }
    var hour:    dispatch_time_t { return dispatch_time(DISPATCH_TIME_NOW, (Int64)(UInt64(self * 3600) * NSEC_PER_SEC)) }
    var hours:   dispatch_time_t { return dispatch_time(DISPATCH_TIME_NOW, (Int64)(UInt64(self * 3600) * NSEC_PER_SEC)) }

}
