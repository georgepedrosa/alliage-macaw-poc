//
//  String+Extensions.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 15/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import Foundation

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    /// Inserts a line break before the last word, used to wrap annotation text
    /// that overflows its bounding box.
    func breakingLastWord() -> String {
        var text = self
        for i in stride(from: text.count - 1, to: 0, by: -1) where text[i] == " " {
            let offset = i == text.count - 1 ? i : i + 1
            text.insert("\n", at: text.index(text.startIndex, offsetBy: offset))
            break
        }
        return text
    }
}
