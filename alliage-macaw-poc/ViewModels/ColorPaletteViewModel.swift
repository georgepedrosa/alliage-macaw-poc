//
//  ColorPaletteViewModel.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 11/11/26.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import UIKit

/// Provides the fixed palette shown by ColorSelectorView, converting the raw
/// hex strings into ready-to-use colors and values.
struct ColorPaletteViewModel {

    private let hexStrings = App.Colors.stringArray

    var numberOfColors: Int {
        hexStrings.count
    }

    func colorValue(at index: Int) -> Int {
        Int(hexStrings[index], radix: 16) ?? 0
    }

    func color(at index: Int) -> UIColor {
        UIColor(rgb: colorValue(at: index))
    }
}
