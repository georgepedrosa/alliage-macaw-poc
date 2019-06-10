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
    var path: PathBuilder!
    
    required init(startPoint: Point, lastPoint: Point) {
        super.init()
        
        path = MoveTo(x: startPoint.x, y: startPoint.y)
        path = path.lineTo(x: startPoint.x, y: startPoint.y)
        
        drawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: Color.red,
                width: 4,
                cap: .round
            )
        )
        
        contents = [drawing]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        path = path.lineTo(x: lastPoint.x, y: lastPoint.y)
        self.drawing.form = path.build()
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
        return nil
    }
    
    func activateCircleAction() {
        
    }
    
}
