//
//  DateExtension.swift
//  mdimore
//
//  Created by Michael Dimore on 4/29/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import Foundation

extension Date {
    func timeAgoPosted() -> String {
        
        let secs = abs(Int(timeIntervalSinceNow))
        let mins = secs/60
        let hrs  = mins/60
        let days = hrs/24
        let yrs  = days/365
        
        if yrs >= 1 {
            return "• \(yrs)y"
        } else if days >= 1 {
            return "• \(days)d"
        } else if hrs >= 1 {
            return "• \(hrs)h"
        } else if mins >= 1 {
            return "• \(mins)m"
        } else {
            return "• \(secs)s"
        }
    }
}
