//
//  NSLayoutConstraint+extension.swift
//  Balinasoft
//
//  Created by MAC on 11/6/24.
//

import UIKit

extension NSLayoutConstraint {
    ///Set ``priority`` to `.defaultLow` and return ``self``.
    var lowPriority: NSLayoutConstraint {
        self.priority = .defaultLow
        return self
    }
    
    ///Set ``priority`` to `.defaultHigh` and return ``self``.
    var highPriority: NSLayoutConstraint {
        self.priority = .defaultHigh
        return self
    }
}
