//
//  Protractor.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 17/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//
//
//import UIKit
//import Macaw
//
//class Protractor: Group, CustomShape {
//
//    var line1: Shape!
//    var line2: Shape!
//
//    var isActive: Bool = false
//
//    required init(startPoint: Point, lastPoint: Point) {
//        super.init()
//        let locusLine = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
//        line1 = Shape(form: locusLine, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
//
//        let slope1 = (lastPoint.y-startPoint.y)/(lastPoint.x-startPoint.x)
//
//
//
//
//
//        let width = lastPoint.x - startPoint.x
//        let height = lastPoint.y - startPoint.y
//        let locusRect = Rect(x: startPoint.x, y: startPoint.y, w: width, h: height)
//        rect = Shape(form: locusRect, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
//
//        let locusCircle = Circle(cx: lastPoint.x, cy: lastPoint.y, r: 15)
//        circle = Shape(form: locusCircle, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 2.0))
//        contents = [circle, line, rect]
//    }
//
//    func updateForm(startPoint: Point, lastPoint: Point) {
//        self.line.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
//        self.rect.form = Rect(x: startPoint.x, y: startPoint.y, w: lastPoint.x - startPoint.x, h: lastPoint.y - startPoint.y)
//        self.circle.form = Circle(cx: lastPoint.x, cy: lastPoint.y, r: 15)
//    }
//
//    func updateStroke(stroke: Stroke) {
//        line.stroke = stroke
//        rect.stroke = stroke
//        if stroke.fill == Color.blue {
//            circle.stroke = Stroke(fill: Color.green, width: 2.0)
//        } else {
//            circle.stroke = Stroke(fill: Color.clear, width: 2.0)
//        }
//    }
//
//    func getCenter() -> Point? {
//        return rect.bounds?.center()
//    }
//
//    func activateCircleAction() {
//        //        circle.onTap { (event) in
//        //            self.place = Transform.scale(sx: 3, sy: 1)
//        //        }
//        circle.onPan { (event) in
//            print("circle.onPan")
//            //print(event.dx)
//            self.place = Transform.scale(sx: 2, sy: 1)
//        }
//    }
//
//}
