//
//  FreeDrawing.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 07/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class FreeDrawing: Group, CustomShape {
    
    var drawing: Shape!
    var backgroundDrawing: Shape!
    var path: PathBuilder!
    
    var isActive: Bool = false {
        didSet {
            drawing.stroke = (isActive ? Stroke(fill: Color.blue, width: 2.0) : Stroke(fill: Color.red, width: 2.0))
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        path = MoveTo(x: startPoint.x, y: startPoint.y)
        path = path.lineTo(x: startPoint.x, y: startPoint.y)
        
        drawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: stroke.fill,
                width: stroke.width,
                cap: .round
            )
        )
        
        backgroundDrawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: Color.clear,
                width: 30,
                cap: .round
            )
        )
        
        contents = [drawing, backgroundDrawing]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        path = path.lineTo(x: lastPoint.x, y: lastPoint.y)
        self.drawing.form = path.build()
        self.backgroundDrawing.form = path.build()
    }
    
    func updateStroke(stroke: Stroke) {
        drawing.stroke = stroke
    }
    
    func deleteShape() {
        contents = []
    }
    
    func redoShape() {
        contents = [drawing]
    }
    
    func getCenter() -> Point? {
        return self.bounds?.center()
    }
    
    func activateCircleAction() {
        
    }
    
}
