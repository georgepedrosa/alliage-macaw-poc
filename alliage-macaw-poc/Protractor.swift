//
//  Protractor.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 17/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class Protractor: Group, CustomShape {
    
    var line1: Shape!
    var line2: Shape!
    var circle0: Shape!
    var circle1: Shape!
    var circle2: Shape!
    var arc: Shape!
    var text: Text!
    
    var x0: Double!
    var y0: Double!
    var x1: Double!
    var y1: Double!
    var x2: Double!
    var y2: Double!
    
    let degreesPerRadian: Double = 57.2958

    var isActive: Bool = false

    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()

        x0 = startPoint.x
        y0 = startPoint.y
        
        x1 = lastPoint.x
        y1 = lastPoint.y
        
        let x2: Double!
        let y2: Double!
        
        let d = distance(startPoint, lastPoint)
        
        let angle = atan2(y1 - y0, x1 - x0)
        
        x2 = x0 + d * cos(angle + Double.pi/4)
        y2 = y0 + d * sin(angle + Double.pi/4)
        
        let locusLine1 = Line(x0, y0, x1, y1)
        let locusLine2 = Line(x0, y0, x2, y2)
        
        line1 = Shape(form: locusLine1, fill: Color.clear, stroke: stroke)
        line2 = Shape(form: locusLine2, fill: Color.clear, stroke: stroke)
        
        let locusCircle0 = Circle(cx: x0, cy: y0, r: 15)
        circle0 = Shape(form: locusCircle0, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        let locusCircle1 = Circle(cx: x1, cy: y1, r: 15)
        circle1 = Shape(form: locusCircle1, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        let locusCircle2 = Circle(cx: x2, cy: y2, r: 15)
        circle2 = Shape(form: locusCircle2, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        
        let ellipseLocus = Ellipse(cx: x0, cy: y0, rx: 40, ry: 40)
        
        let theta1 = atan2(y1 - y0, x1 - x0)
        let theta2 = atan2(y2 - y0, x2 - x0)
        
        let arcLocus = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
        
        arc = Shape(form: arcLocus, fill: Color.clear, stroke: Stroke(fill: Color.orange, width: 5.0))
        
        let angleInDegrees = (Double.pi/4)*degreesPerRadian
        
        text = Text(text: String(format: "%.2f", angleInDegrees) + "º", fill: Color.blue, place: .move(x0, y0))
        
        contents = [arc, line1, line2, circle0, circle1, circle2, text]
    }

    func updateForm(startPoint: Point, lastPoint: Point) {
        
        let x2: Double!
        let y2: Double!
        
        let d = distance(startPoint, lastPoint)
        
        let angle = atan2(lastPoint.y - startPoint.y, lastPoint.x - startPoint.x)
        
        x2 = startPoint.x + d * cos(angle + Double.pi/4)
        y2 = startPoint.y + d * sin(angle + Double.pi/4)
        
        self.line1.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        self.x1 = lastPoint.x
        self.y1 = lastPoint.y
        self.line2.form = Line(startPoint.x, startPoint.y, x2, y2)
        self.x2 = x2
        self.y2 = y2
        
        self.circle1.form = Circle(cx: lastPoint.x, cy: lastPoint.y, r: 15)
        self.circle2.form = Circle(cx: x2, cy: y2, r: 15)
        
        let ellipseLocus = Ellipse(cx: x0, cy: y0, rx: 40, ry: 40)
        
        let theta1 = atan2(y1 - y0, x1 - x0)
        let theta2 = atan2(y2 - y0, x2 - x0)

        self.arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
        
        var angleText = theta1 + ((theta2 - theta1)/2)
        
//        print("a) " + String(Double.pi * (3/4)))
//        print("b) " + String(theta2 - theta1))
        
        if theta2 >= -Double.pi && theta2 <= -Double.pi * (3/4) && theta1 <= Double.pi && theta1 >= Double.pi * (3/4) {
            angleText = Double.pi + angleText
        }
        
        let distanceText = 70.0
        
        let textX = distanceText * cos(angleText) + x0
        let textY = distanceText * sin(angleText) + y0
        
        self.text.place = .move(dx: textX, dy: textY)
        
        //print("theta1: " + String(theta1*degreesPerRadian))
        //print("theta2: " + String(theta2*degreesPerRadian))
        //print("angleText: " + String(angleText*degreesPerRadian ))
        
    }
    
    func moveCircle(circle: ProtractorCircle, toPoint loc: Point) {
        
        switch circle {
        case .zero:
            circle0.form = Circle(cx: loc.x, cy: loc.y, r: 15)
            line1.form = Line(loc.x, loc.y, x1, y1)
            line2.form = Line(loc.x, loc.y, x2, y2)
            x0 = loc.x
            y0 = loc.y
            
            let ellipseLocus = Ellipse(cx: x0, cy: y0, rx: 40, ry: 40)
            
            let theta1 = atan2(y1 - y0, x1 - x0)
            let theta2 = atan2(y2 - y0, x2 - x0)
            
            var angleInDegrees = (theta2-theta1)*degreesPerRadian
            if angleInDegrees < 0 {
                angleInDegrees += 360
            }
            
            arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
            
            text.text = String(format: "%.2f", angleInDegrees) + "º"
            
            var angleText = theta1 + ((theta2 - theta1)/2)
            
            if theta2 >= -Double.pi && theta2 <= -Double.pi * (3/4) && theta1 <= Double.pi && theta1 >= Double.pi * (3/4) {
                angleText = Double.pi + angleText
            }
            
            let distanceText = 70.0
            
            let textX = distanceText * cos(angleText) + x0
            let textY = distanceText * sin(angleText) + y0
            
            text.place = .move(dx: textX, dy: textY)

        case .one:
            line1.form = Line(x0, y0, loc.x, loc.y)
            circle1.form = Circle(cx: loc.x, cy: loc.y, r: 15)
            x1 = loc.x
            y1 = loc.y
            
            let ellipseLocus = Ellipse(cx: x0, cy: y0, rx: 40, ry: 40)
            
            let theta1 = atan2(y1 - y0, x1 - x0)
            let theta2 = atan2(y2 - y0, x2 - x0)
            
            var angleInDegrees = (theta2-theta1)*degreesPerRadian
            if angleInDegrees < 0 {
                angleInDegrees += 360
            }
            
            arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
            text.text = String(format: "%.2f", angleInDegrees) + "º"
            
            var angleText = theta1 + ((theta2 - theta1)/2)
            
            if theta2 >= -Double.pi && theta2 <= -Double.pi * (3/4) && theta1 <= Double.pi && theta1 >= Double.pi * (3/4) {
                angleText = Double.pi + angleText
            }
            
            let distanceText = 70.0
            
            let textX = distanceText * cos(angleText) + x0
            let textY = distanceText * sin(angleText) + y0
            
            text.place = .move(dx: textX, dy: textY)
            
        case .two:
            line2.form = Line(x0, y0, loc.x, loc.y)
            circle2.form = Circle(cx: loc.x, cy: loc.y, r: 15)
            x2 = loc.x
            y2 = loc.y
            
            let ellipseLocus = Ellipse(cx: x0, cy: y0, rx: 40, ry: 40)
            
            let theta1 = atan2(y1 - y0, x1 - x0)
            let theta2 = atan2(y2 - y0, x2 - x0)
            
            var angleInDegrees = (theta2-theta1)*degreesPerRadian
            if angleInDegrees < 0 {
                angleInDegrees += 360
            }
            
            arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
            text.text = String(format: "%.2f", angleInDegrees) + "º"
            
            var angleText = theta1 + ((theta2 - theta1)/2)
            
            if theta2 >= -Double.pi && theta2 <= -Double.pi * (3/4) && theta1 <= Double.pi && theta1 >= Double.pi * (3/4) {
                angleText = Double.pi + angleText
            }
            
            let distanceText = 70.0
            
            let textX = distanceText * cos(angleText) + x0
            let textY = distanceText * sin(angleText) + y0
            
            text.place = .move(dx: textX, dy: textY)
        }
        
    }

    func updateStroke(stroke: Stroke) {
        line1.stroke = stroke
        line2.stroke = stroke
    }

    func getCenter() -> Point? {
        return line1.bounds?.center()
    }

    func activateCircleAction() {
        
    }
    
    func distance(_ a: Point, _ b: Point) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func getAngle(vertex: Point, pointA: Point, pointB: Point) -> Double {
        //arccos((P122 + P132 - P232) / (2 * P12 * P13))
        
        return acos((pow(distance(vertex, pointA), 2.0) + pow(distance(vertex, pointB), 2.0) - pow(distance(pointA, pointB), 2.0)) / (2 * distance(vertex, pointA) * distance(vertex, pointB)))
    }
}

enum ProtractorCircle {
    case zero
    case one
    case two
}
