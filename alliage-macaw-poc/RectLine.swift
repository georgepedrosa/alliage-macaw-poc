//
//  RectLine.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 05/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class RectLine: Group, CustomShape {
    var delegate: MacawViewDelegate!
    var line: Shape!
    var rect: Shape!
    var circle: Shape!
    
    var isActive: Bool = false {
        didSet {
            if isActive {
                rect.stroke = Stroke(fill: Color.blue, width: 5.0)
                line.stroke = Stroke(fill: Color.blue, width: 5.0)
                circle.stroke = Stroke(fill: Color.green, width: 5.0)
            } else {
                rect.stroke = Stroke(fill: Color.red, width: 5.0)
                line.stroke = Stroke(fill: Color.red, width: 5.0)
                circle.stroke = Stroke(fill: Color.clear, width: 5.0)
            }
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        let locusLine = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        line = Shape(form: locusLine, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 5.0))
        
        let width = lastPoint.x - startPoint.x
        let height = lastPoint.y - startPoint.y
        let locusRect = Rect(x: startPoint.x, y: startPoint.y, w: width, h: height)
        rect = Shape(form: locusRect, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 5.0))
        
        let locusCircle = Circle(cx: lastPoint.x, cy: lastPoint.y, r: 15)
        circle = Shape(form: locusCircle, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        contents = [circle, line, rect]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        self.line.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        self.rect.form = Rect(x: startPoint.x, y: startPoint.y, w: lastPoint.x - startPoint.x, h: lastPoint.y - startPoint.y)
        self.circle.form = Circle(cx: lastPoint.x, cy: lastPoint.y, r: 15)
    }
    
    func updateStroke(stroke: Stroke) {
        line.stroke = stroke
        rect.stroke = stroke
        if stroke.fill == Color.blue {
            circle.stroke = Stroke(fill: Color.green, width: 5.0)
        } else {
            circle.stroke = Stroke(fill: Color.clear, width: 5.0)
        }
    }
    
    func getCenter() -> Point? {
        return rect.bounds?.center()
    }
    
    func setTransformEvents() {
//        circle.onTap { (event) in
//            self.place = Transform.scale(sx: 3, sy: 1)
//        }
        circle.onPan { (event) in
            print("circle.onPan")
            //print(event.dx)
            self.place = Transform.scale(sx: 2, sy: 1)
        }
    }
    
}
