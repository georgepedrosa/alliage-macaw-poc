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
    var delegate: MacawViewDelegate!
    var stroke: Stroke!
    
    var drawing: Shape!
    var backgroundDrawing: Shape!
    var path: PathBuilder!
    var backgroundRect: Shape!
    
    var isActive: Bool = false {
        didSet {
            contents = (isActive ? [drawing, backgroundDrawing, backgroundRect] : [drawing, backgroundDrawing])
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        self.stroke = stroke
        
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
        
        backgroundRect = Shape(form: drawing.form.bounds(), fill: Color.clear, stroke: Stroke(fill: Color.blue, width: stroke.width))
        contents = [drawing, backgroundDrawing]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        path = path.lineTo(x: lastPoint.x, y: lastPoint.y)
        drawing.form = path.build()
        backgroundDrawing.form = path.build()
        backgroundRect.form = drawing.form.bounds()
    }
    
    func updateStroke(stroke: Stroke) {
        drawing.stroke = stroke
    }
    
    func deleteShape() {
        contents = []
    }
    
    func redoShape() {
        contents = [drawing]
        isActive = false
    }
    
    func getCenter() -> Point? {
        return self.bounds?.center()
    }
    
    func setTransformEvents() {
        backgroundRect.onPan { (event) in
            guard let _ = event.node else { print("problem on pan")
                return
            }
            if !self.isActive { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
            self.delegate.activateScrollView(enable: true)
        }
    }
}
