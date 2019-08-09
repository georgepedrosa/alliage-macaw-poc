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
    var backgroundLine1: Shape!
    var backgroundLine2: Shape!
    var circle0: Shape!
    var circle1: Shape!
    var circle2: Shape!
    var arc: Shape!
    var text: Text!
    
    var p0: Point!
    var p1: Point!
    var p2: Point!
    
    let degreesPerRadian: Double = 57.2958
    let protractorAngle = Double.pi/4

    var isActive: Bool = true {
        didSet {
            if isActive {
                contents = [arc, line1, line2, backgroundLine1, backgroundLine2, circle0, circle1, circle2, text]
                line1.stroke = Stroke(fill: Color.blue, width: self.stroke.width)
                line2.stroke = Stroke(fill: Color.blue, width: self.stroke.width)
            } else {
                contents = [arc, line1, line2, backgroundLine1, backgroundLine2, text]
                line1.stroke = stroke
                line2.stroke = stroke
            }
        }
    }
    
    var delegate: MacawViewDelegate!
    
    var stroke: Stroke!
    
    init(p0: Point, p1: Point, p2: Point, delegate: MacawViewDelegate, stroke: Stroke) {
        super.init()
        self.delegate = delegate
        self.stroke = stroke

        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        
        let locusLine1 = Line(p0.x, p0.y, p1.x, p1.y)
        let locusLine2 = Line(p0.x, p0.y, p2.x, p2.y)
        
        line1 = Shape(form: locusLine1, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: self.stroke.width))
        line2 = Shape(form: locusLine2, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: self.stroke.width))
        backgroundLine1 = Shape(form: locusLine1, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        backgroundLine2 = Shape(form: locusLine2, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let locusCircle0 = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle0 = Shape(form: locusCircle0, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        let locusCircle1 = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle1 = Shape(form: locusCircle1, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        let locusCircle2 = Circle(cx: p2.x, cy: p2.y, r: 15)
        circle2 = Shape(form: locusCircle2, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        
        let ellipseLocus = Ellipse(cx: p0.x, cy: p0.y, rx: 40, ry: 40)
        
        let theta1 = atan2(p1.y - p0.y, p1.x - p0.x)
        let theta2 = atan2(p2.y - p0.y, p2.x - p0.x)
        
        var angleInDegrees = (theta2-theta1)*degreesPerRadian
        if angleInDegrees < 0 {
            angleInDegrees += 360
        }

        let arcLocus = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
        
        arc = Shape(form: arcLocus, fill: Color.clear, stroke: Stroke(fill: Color.orange, width: self.stroke.width))
        
        text = Text(text: String(format: "%.2f", angleInDegrees) + "º", fill: Color.blue, place: .move(p0.x, p0.y))
        
        var angleText = theta1 + ((theta2 - theta1)/2)
        
        if theta2 >= -Double.pi && theta2 <= -(Double.pi - angleText) && theta1 <= Double.pi && theta1 >= Double.pi - angleText {
            angleText = Double.pi + angleText
        }
        
        let distanceText = 70.0
        
        let textX = distanceText * cos(angleText) + p0.x
        let textY = distanceText * sin(angleText) + p0.y
        
        text.place = .move(dx: textX, dy: textY)
        
        contents = [arc, line1, line2, backgroundLine1, backgroundLine2, circle0, circle1, circle2, text]
    }

    func updateForm(startPoint: Point, lastPoint: Point) {
        
        let d = distance(startPoint, lastPoint)
        let angle = atan2(lastPoint.y - startPoint.y, lastPoint.x - startPoint.x)
        
        self.p0 = startPoint
        self.p1 = lastPoint
        self.p2 = Point(x: startPoint.x + d * cos(angle + protractorAngle), y: startPoint.y + d * sin(angle + protractorAngle))

        updateFormFromPoints()
    }
    
    func setTransformEvents() {
        self.circle0.onTouchMoved { (event) in
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP0 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            self.p0 = newP0
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        self.circle1.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP1 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            self.p1 = newP1
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        self.circle2.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP2 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            self.p2 = newP2
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        self.backgroundLine1.onPan { (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            
            if !self.isActive { return }
            
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
            self.delegate.activateScrollView(enable: true)
        }
        self.backgroundLine2.onPan { (event) in
            guard let _ = event.node else { print("problem on arc pan")
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
    
    func updateFormFromPoints() {
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle2.form = Circle(cx: p2.x, cy: p2.y, r: 15)
        line1.form = Line(p0.x, p0.y, p1.x, p1.y)
        backgroundLine1.form = Line(p0.x, p0.y, p1.x, p1.y)
        line2.form = Line(p0.x, p0.y, p2.x, p2.y)
        backgroundLine2.form = Line(p0.x, p0.y, p2.x, p2.y)
        
        let ellipseLocus = Ellipse(cx: p0.x, cy: p0.y, rx: 40, ry: 40)
        
        let theta1 = atan2(p1.y - p0.y, p1.x - p0.x)
        let theta2 = atan2(p2.y - p0.y, p2.x - p0.x)
        
        var angleInDegrees = (theta2-theta1)*degreesPerRadian
        if angleInDegrees < 0 {
            angleInDegrees += 360
        }
        
        arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
        
        text.text = String(format: "%.2f", angleInDegrees) + "º"
        
        var angleText = theta1 + ((theta2 - theta1)/2)
        
        if theta2 >= -Double.pi && theta2 <= -(Double.pi - angleText) && theta1 <= Double.pi && theta1 >= Double.pi - angleText {
            angleText = Double.pi + angleText
        }
        
        let distanceText = 70.0
        
        let textX = distanceText * cos(angleText) + p0.x
        let textY = distanceText * sin(angleText) + p0.y
        
        text.place = .move(dx: textX, dy: textY)
    }

    func updateStroke(stroke: Stroke) {
        self.stroke = stroke
        line1.stroke = stroke
        line2.stroke = stroke
    }

    func getCenter() -> Point? {
        return line1.bounds?.center()
    }

    func distance(_ a: Point, _ b: Point) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
//    func getAngle(vertex: Point, pointA: Point, pointB: Point) -> Double {
//        //arccos((P122 + P132 - P232) / (2 * P12 * P13))
//
//        return acos((pow(distance(vertex, pointA), 2.0) + pow(distance(vertex, pointB), 2.0) - pow(distance(pointA, pointB), 2.0)) / (2 * distance(vertex, pointA) * distance(vertex, pointB)))
//    }
}

enum ProtractorCircle {
    case zero
    case one
    case two
}
