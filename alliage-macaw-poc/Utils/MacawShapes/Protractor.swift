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
    
    var annotationId: Int!
    var id: Int!
    var type: Annotation.Types!
    var comment: String = ""
    
    var line1: Shape!
    var line2: Shape!
    var backgroundLine1: Shape!
    var backgroundLine2: Shape!
    var circle0: Shape!
    var circle1: Shape!
    var circle2: Shape!
    var anchor0: Shape!
    var anchor1: Shape!
    var anchor2: Shape!
    var arc: Shape!
    var text: Text!
    var idText: Text!
    
    var p0: Point!
    var p1: Point!
    var p2: Point!
    
    var degreesPerRadian = App.Constants.degreesPerRadian
    let protractorAngle = Double.pi/4
    
    var activeContents: [Node]!
    var inactiveContents: [Node]!

    var isActive: Bool = true {
        didSet {
            isHidden = false
        }
    }
    
    var isHidden: Bool = false {
        didSet {
            if isHidden {
                contents = []
            } else {
                contents = isActive ? activeContents : inactiveContents
            }
        }
    }
    
    weak var delegate: MacawViewDelegate?
    
    var stroke: Stroke!
    
    init(p0: Point, p1: Point, p2: Point, delegate: MacawViewDelegate, stroke: Stroke, type: Annotation.Types, id: Int? = nil, annotationId: Int, comment: String) {
        super.init()
        self.delegate = delegate
        self.stroke = stroke
        self.type = type
        self.id = id
        self.annotationId = annotationId
        self.comment = comment

        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        
        line1 = Shape(form: Line(), fill: Color.clear, stroke: stroke)
        line2 = Shape(form: Line(), fill: Color.clear, stroke: stroke)
        backgroundLine1 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        backgroundLine2 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        circle0 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle1 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle2 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        anchor0 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor1 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor2 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        arc = Shape(form: Ellipse(), fill: Color.clear, stroke: stroke)
        text = Text(text: "", fill: stroke.fill, place: .move(p0.x, p0.y))
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill
        
        activeContents = [arc, line1, line2, backgroundLine1, backgroundLine2, anchor0, anchor1, anchor2, idText, text, circle0, circle1, circle2]
        inactiveContents = [arc, line1, line2, backgroundLine1, backgroundLine2, text]
        contents = activeContents
        updateFormFromPoints()
    }

    func updateForm(startPoint: Point, lastPoint: Point) {
        
        let d = distance(startPoint, lastPoint)
        let angle = atan2(lastPoint.y - startPoint.y, lastPoint.x - startPoint.x)
        
        self.p0 = startPoint
        self.p1 = lastPoint
        self.p2 = Point(x: startPoint.x + d * cos(angle + Double.pi/4), y: startPoint.y + d * sin(angle + protractorAngle))

        updateFormFromPoints()
    }
    
    func setTransformEvents() {
        self.circle0.onTouchMoved { [weak self] (event) in
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            //let transform = self.delegate.shapeTransformations[self.hash]
            let newP0 = Point(x: loc.x, y: loc.y)
            self?.p0 = newP0
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        self.circle1.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            //let transform = self.delegate.shapeTransformations[self.hash]
            let newP1 = Point(x: loc.x, y: loc.y)
            self?.p1 = newP1
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        self.circle2.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            //let transform = self.delegate.shapeTransformations[self.hash]
            let newP2 = Point(x: loc.x, y: loc.y)
            self?.p2 = newP2
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        self.backgroundLine1.onPan { [weak self] (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            
            if !self!.isActive { return }
            
            self?.delegate?.activateScrollView(enable: false)
            self?.move(dx: event.dx, dy: event.dy)
            self?.delegate?.activateScrollView(enable: true)
        }
        self.backgroundLine2.onPan { [weak self] (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            
            if !self!.isActive { return }
            
            self?.delegate?.activateScrollView(enable: false)
            self?.move(dx: event.dx, dy: event.dy)
            self?.delegate?.activateScrollView(enable: true)
        }
    }
    
    func updateFormFromPoints() {
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle2.form = Circle(cx: p2.x, cy: p2.y, r: 15)
        anchor0.form = Rect(x: p0.x-4, y: p0.y-4, w: 8, h: 8)
        anchor1.form = Rect(x: p1.x-4, y: p1.y-4, w: 8, h: 8)
        anchor2.form = Rect(x: p2.x-4, y: p2.y-4, w: 8, h: 8)
        line1.form = Line(p0.x, p0.y, p1.x, p1.y)
        backgroundLine1.form = Line(p0.x, p0.y, p1.x, p1.y)
        line2.form = Line(p0.x, p0.y, p2.x, p2.y)
        backgroundLine2.form = Line(p0.x, p0.y, p2.x, p2.y)
        
        let ellipseLocus = Ellipse(cx: p0.x, cy: p0.y, rx: 40, ry: 40)
        
        let theta1 = atan2(p1.y - p0.y, p1.x - p0.x)
        let theta2 = atan2(p2.y - p0.y, p2.x - p0.x)
        let currentAngle = theta2 - theta1 < 0 ? (theta2 - theta1) + 2*Double.pi : theta2 - theta1

        if currentAngle < Double.pi {
            arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: currentAngle)
            text.text = String(format: "%.2f", currentAngle*degreesPerRadian) + "º"
        } else {
            arc.form = Arc(ellipse: ellipseLocus, shift: theta2, extent: (2*Double.pi) - (currentAngle))
            text.text = String(format: "%.2f", ((2*Double.pi) - (currentAngle))*degreesPerRadian) + "º"
        }

        var angleInDegrees = (theta2-theta1)*degreesPerRadian
        if angleInDegrees < 0 {
            angleInDegrees += 360
        }
        
        text.place = .move(dx: p0.x, dy: p0.y)
        idText.place = .move(dx: p1.x+5, dy: p1.y-20)
    }

    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
        self.stroke = stroke
        idText.fill = self.stroke.fill
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
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        p1 = Point(x: p1.x + dx, y: p1.y + dy)
        p2 = Point(x: p2.x + dx, y: p2.y + dy)
        updateFormFromPoints()
    }
}

enum ProtractorCircle {
    case zero
    case one
    case two
}
