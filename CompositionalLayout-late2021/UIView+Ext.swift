//
//  UIView+Ext.swift
//  CompositionalLayout-late2021
//
//  Created by Marcus Ziadé on 6.11.2021.
//

import UIKit

extension UIView {
    
    func forAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
