//
//  Multiline.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 22/07/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class Multiline: Group, CustomShape {
    
    var drawing: Shape!
    var backgroundDrawing: Shape!
    var points: [Point] = []
    //var backgroundDrawing: Shape!
    
    var isActive: Bool = true
    var stroke: Stroke!
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        self.stroke = stroke
        self.points.append(startPoint)
        
        var path: PathBuilder = MoveTo(x: startPoint.x, y: startPoint.y)
        path = path.lineTo(x: startPoint.x + 1, y: startPoint.y + 1)
        
        drawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: stroke.fill,
                width: stroke.width,
                cap: .round
            )
        )
        
        backgroundDrawing  = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: Color.clear,
                width: 30,
                cap: .round
            )
        )
        
        contents = [drawing, backgroundDrawing]
    }
    
    init(points: [Point], stroke: Stroke) {
        super.init()
        
        self.stroke = stroke
        self.points = points
        
        var path: PathBuilder = MoveTo(x: points[0].x, y: points[0].y)
        
        for point in points {
            path = path.lineTo(x: point.x, y: point.y)
        }
        
        drawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: stroke.fill,
                width: stroke.width,
                cap: .round
            )
        )
        
        backgroundDrawing  = Shape(
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
        
    }
    
    func newPoint(point: Point) {
        points.append(point)
        
        var path: PathBuilder = MoveTo(x: points[0].x, y: points[0].y)
        for point in points {
            path = path.lineTo(x: point.x, y: point.y)
        }
        
        drawing.form = path.build()
        backgroundDrawing.form = path.build()
    }
    
    func updateStroke(stroke: Stroke) {
        
    }
    
    func getCenter() -> Point? {
        return Point()
    }
}
