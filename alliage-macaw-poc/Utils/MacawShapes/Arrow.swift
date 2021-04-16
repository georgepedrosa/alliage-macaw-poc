//
//  Arrow.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 05/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

// Arrow calculations: https://math.stackexchange.com/questions/1314006/drawing-an-arrow

import UIKit
import Macaw

class Arrow: Group, CustomShape {
    
    var annotationId: Int!
    var id: Int!
    let headAngle = Double.pi/6
    
    weak var delegate: MacawViewDelegate?
    var stroke: Stroke!
    
    var p0: Point!
    var p1: Point!

    var line: Shape!
    var head: Shape!
    var backgroundLine: Shape!
    
    var circle0: Shape!
    var circle1: Shape!
    
    var anchor0: Shape!
    var anchor1: Shape!
    
    var idText: Text!
    
    var type: Annotation.Types!
    var comment: String = ""
    
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
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke, type: Annotation.Types, id: Int? = nil, annotationId: Int, comment: String) {
        super.init()
        
        self.stroke = stroke
        self.type = type
        self.id = id
        self.annotationId = annotationId
        self.comment = comment
        
        p0 = startPoint
        p1 = lastPoint
        
        line = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: stroke.fill, width: stroke.width))
        backgroundLine = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        var path: PathBuilder = MoveTo(x: startPoint.x, y: startPoint.y)
        path = path.lineTo(x: startPoint.x, y: startPoint.y)
        
        head = Shape(
            form: path.build(),
            fill: stroke.fill,
            stroke: Stroke(
                fill: stroke.fill,
                width: 1.0,
                cap: .round
            )
        )
        
        circle0 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle1 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        anchor0 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor1 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill
        
        activeContents = [line, backgroundLine, head, idText, anchor0, anchor1, circle0, circle1]
        inactiveContents = [line, backgroundLine, head]
        contents = activeContents
        
        updateFormFromPoints()
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        p0 = startPoint
        p1 = lastPoint
        updateFormFromPoints()
    }
    
    func setTransformEvents() {
        circle0.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            let newP0 = Point(x: loc.x, y: loc.y)
            self?.p0 = newP0
            self?.updateFormFromPoints()
        }
        
        circle1.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            let newP1 = Point(x: loc.x, y: loc.y)
            self?.p1 = newP1
            self?.updateFormFromPoints()
        }
        backgroundLine.onPan { [weak self] (event) in
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
        let x1 = p0.x
        let y1 = p0.y
        
        let x2 = p1.x
        let y2 = p1.y
        
        let l1 = distance(p0, p1)
        let l2 = (stroke.width*3)/2
        
        let x3 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(headAngle) ) + ( (y1-y2) * (sin(headAngle) ) ) ) )
        let y3 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(headAngle) ) - ( (x1-x2) * (sin(headAngle) ) ) ) )
        let x4 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(headAngle) ) - ( (y1-y2) * (sin(headAngle) ) ) ) )
        let y4 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(headAngle) ) + ( (x1-x2) * (sin(headAngle) ) ) ) )
        
        let x5 = (x3 + x4)/2
        let y5 = (y3 + y4)/2
        
        line.form = Line(p0.x, p0.y, x5, y5)
        backgroundLine.form = Line(p0.x, p0.y, x5, y5)
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 20)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 20)
        anchor0.form = Rect(x: p0.x-4, y: p0.y-4, w: 8, h: 8)
        anchor1.form = Rect(x: p1.x-4, y: p1.y-4, w: 8, h: 8)
        idText.place = .move(dx: p0.x, dy: p0.y - 20)
        
        var path: PathBuilder = MoveTo(x: x3, y: y3)
        path = path.lineTo(x: x3, y: y3)
        path = path.lineTo(x: x2, y: y2)
        path = path.lineTo(x: x4, y: y4)
        path = path.lineTo(x: x3, y: y3)
        
        head.form = path.build()
    }
    
    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
        self.stroke = stroke
        line.stroke = stroke
        idText.fill = self.stroke.fill
        updateFormFromPoints()
    }
    
    func getCenter() -> Point? {
        return line.bounds?.center()
    }
    
    func distance(_ a: Point, _ b: Point) -> Double {
        
        if a == b { return 0.0001 }
        
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        p1 = Point(x: p1.x + dx, y: p1.y + dy)
        updateFormFromPoints()
    }
}
