//
//  UILabel+Extensions.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 21/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import UIKit

extension UIButton {
    func setColoredButtonText() {
        let str = "Color"
        let colors:[UIColor] = [
            .red,       // C
            .systemGreen,     // o
            .blue,      // l
            .purple,      // o
            .orange,    // r
        ]
        let attrStr = NSMutableAttributedString()
        for (chr, color) in zip(str, colors) {
            attrStr.append(
                NSAttributedString(string: String(chr), attributes: [NSAttributedString.Key.foregroundColor:color])
            )
        }
        self.setAttributedTitle(attrStr, for: .normal)
    }
}
