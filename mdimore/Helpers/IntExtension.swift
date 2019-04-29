//
//  IntExtension.swift
//  mdimore
//
//  Created by Michael Dimore on 4/29/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import Foundation

extension Int {
    
    func formatUsingAbbrevation () -> String {
        let numFormatter = NumberFormatter()
        let value = self >= 1000 ? (Double(self) / 1000.0) : Double(self)
        numFormatter.positiveSuffix = self >= 1000 ? "k" : ""
        numFormatter.minimumFractionDigits = self >= 1000 ? 1 : 0
        numFormatter.maximumFractionDigits = 1
        return numFormatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
