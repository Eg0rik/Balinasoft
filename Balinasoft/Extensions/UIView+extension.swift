//
//  UIView+extension.swift
//  Balinasoft
//
//  Created by MAC on 11/6/24.
//

import UIKit

extension UIView {
    
    ///Add subviews and set `translatesAutoresizingMaskIntoConstraints` to false.
    func addSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
}
