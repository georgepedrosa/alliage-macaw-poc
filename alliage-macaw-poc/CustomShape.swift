//
//  CustomShape.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 06/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

protocol CustomShape: Node {
    init(startPoint: Point, lastPoint: Point)
    func updateForm(startPoint: Point, lastPoint: Point)
    func updateStroke(stroke: Stroke)
    func getCenter() -> Point?
    func activateCircleAction()
}
