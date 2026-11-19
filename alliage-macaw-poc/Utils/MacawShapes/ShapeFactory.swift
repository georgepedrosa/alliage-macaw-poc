//
//  ShapeFactory.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 11/11/26.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import Foundation
import Macaw

/// Factory for the auxiliary Macaw shapes shared by every custom annotation
/// (invisible drag handles and the small white resize anchors). Centralising
/// them removes the literal that was repeated dozens of times across shapes.
enum ShapeFactory {

    /// Invisible, wide circle used as a touch target for resize handles.
    static func handle() -> Shape {
        Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
    }

    /// Small white square drawn at a shape's corner/midpoint while selected.
    static func anchor() -> Shape {
        Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
    }
}

extension Point {

    /// Euclidean distance to another point. Returns a tiny non-zero value for
    /// coincident points so callers can safely divide by it.
    func distance(to other: Point) -> Double {
        if self == other { return 0.0001 }
        let dx = x - other.x
        let dy = y - other.y
        return (dx * dx + dy * dy).squareRoot()
    }
}
