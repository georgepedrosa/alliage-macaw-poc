//
//  ColorSelectorViewModel.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 11/11/26.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import Foundation
import Macaw

/// Drives the color selector popup: holds the currently picked color and the
/// annotation the color should be applied to, and notifies the coordinator
/// (view controller) when the user confirms or cancels.
final class ColorSelectorViewModel {

    static let defaultColorValue = 0xffffff

    let selectedColorValue = Observable<Int>(ColorSelectorViewModel.defaultColorValue)

    /// Annotation targeted by the color change, or nil when no shape is selected.
    var annotationId: Int?

    var onConfirm: ((Color, Int?) -> Void)?
    var onCancel: (() -> Void)?

    func select(colorValue: Int) {
        selectedColorValue.value = colorValue
    }

    func confirm() {
        onConfirm?(Color(val: selectedColorValue.value), annotationId)
    }

    func cancel() {
        selectedColorValue.value = ColorSelectorViewModel.defaultColorValue
        onCancel?()
    }
}
