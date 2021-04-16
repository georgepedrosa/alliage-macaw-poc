//
//  CustomShape.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 06/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

protocol CustomShape: Group {
    var delegate: MacawViewDelegate? { get set }
    var isActive: Bool { get set }
    var isHidden: Bool { get set }
    func updateForm(startPoint: Point, lastPoint: Point)
    func updateStroke(stroke: Stroke, stroke2: Stroke?)
    func getCenter() -> Point?
    func setTransformEvents()
    var stroke: Stroke! { get set }
    var id: Int! { get }
    var type: Annotation.Types! { get set }
    var annotationId: Int! { get set }
    var activeContents: [Node]! { get }
    var inactiveContents: [Node]! { get }
    var comment: String { get set }
}
