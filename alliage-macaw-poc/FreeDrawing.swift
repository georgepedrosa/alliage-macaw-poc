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
    
    var points: [Point]!
    
    var isActive: Bool = false {
        didSet {
            contents = (isActive ? [drawing, backgroundDrawing, backgroundRect] : [drawing, backgroundDrawing])
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        self.stroke = stroke
        
        points = [startPoint]
        
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
        points.append(lastPoint)
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
            self.move(dx: event.dx, dy: event.dy)
            self.delegate.activateScrollView(enable: true)
        }
    }
    
    func updateFormFromPoints() {
        path = MoveTo(x: points[0].x, y: points[0].y)
        for i in 1..<points.count {
            path = path.lineTo(x: points[i].x, y: points[i].y)
        }
        drawing.form = path.build()
        backgroundDrawing.form = path.build()
        backgroundRect.form = drawing.form.bounds()
    }
    
    func move(dx: Double, dy: Double) {
        for i in 0..<points.count {
            points[i] = Point(x: points[i].x + dx, y: points[i].y + dy)
        }
        updateFormFromPoints()
    }
}
