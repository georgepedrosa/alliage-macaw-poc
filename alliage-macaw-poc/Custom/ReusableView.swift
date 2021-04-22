//
//  ReusableView.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 19/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import Foundation

protocol ReusableView {
    
    static var reuseIdentifier: String { get }
    
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
