//
//  Observable.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 11/11/26.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import Foundation

/// Lightweight observable box used to bind view model state to the view layer
/// without requiring Combine.
final class Observable<Value> {

    typealias Observer = (Value) -> Void

    var value: Value {
        didSet {
            notifyObservers()
        }
    }

    private var observers: [Observer] = []

    init(_ value: Value) {
        self.value = value
    }

    /// Registers an observer that is called on every subsequent change.
    func bind(_ observer: @escaping Observer) {
        observers.append(observer)
    }

    /// Registers an observer and immediately calls it with the current value.
    func bindAndFire(_ observer: @escaping Observer) {
        bind(observer)
        observer(value)
    }

    private func notifyObservers() {
        observers.forEach { $0(value) }
    }
}
