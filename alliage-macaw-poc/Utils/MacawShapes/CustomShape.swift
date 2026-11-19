//
//  CustomShape.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 06/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import Foundation
import Macaw

/// Surface the shapes need to interact with the drawing session while being
/// manipulated (pan/resize/selection/text editing). Implemented by DrawingViewModel.
protocol ShapeInteractionDelegate: AnyObject {
    var lastActiveShape: CustomShape? { get set }
    var customTexts: [CustomText] { get set }
    var isEditingText: Bool { get set }
    func activateScrollView(enable: Bool)
    func setLastActiveShape(newShape: CustomShape)
}

protocol CustomShape: Group {
    var delegate: ShapeInteractionDelegate? { get set }
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
