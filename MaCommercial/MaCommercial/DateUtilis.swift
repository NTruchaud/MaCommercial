//
//  DateUtilis.swift
//  MaCommercial
//
//  Created by iem on 04/06/2015.
//  Copyright (c) 2015 iem. All rights reserved.
//

import Foundation

extension NSDate {
    // -> Date System Formatted Medium
    func ToDateMediumString() -> NSString? {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle;
        formatter.timeStyle = .NoStyle;
        return formatter.stringFromDate(self)
    }
}