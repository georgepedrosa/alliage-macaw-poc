//
//  CustomArc.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 08/07/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class CustomArc: Group, CustomShape {
    
    var annotationId: Int!
    var id: Int!
    var type: Annotation.Types!
    var comment: String = ""
    
    var idText: Text!
    
    var drawing: Shape!
    var backgroundDrawing: Shape!
    
    var circle0: Shape!
    var circle1: Shape!
    var circle2: Shape!
    
    var line1: Shape!
    var line2: Shape!
    
    var anchor0: Shape!
    var anchor1: Shape!
    var anchor2: Shape!
    
    var p0: Point!
    var p1: Point!
    var p2: Point!
    
    weak var delegate: MacawViewDelegate?
    
    var stroke: Stroke!
    
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
        
        circle0 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle1 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle2 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        anchor0 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor1 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor2 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        line1 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.blue, width: 2.0))
        line2 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.blue, width: 2.0))

        let path: PathBuilder = MoveTo(x: p0.x, y: p0.y)
        
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
        
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill
        
        activeContents = [line1, line2, drawing, backgroundDrawing, anchor0, anchor1, anchor2, idText, circle0, circle1, circle2]
        inactiveContents = [drawing, backgroundDrawing]
        contents = activeContents
        
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
        self.backgroundDrawing.onPan { [weak self] (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            if !self!.isActive { return }
            self?.delegate?.activateScrollView(enable: false)
            self?.move(dx: event.dx, dy: event.dy)
            self?.delegate?.activateScrollView(enable: true)
        }
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        
        p0 = startPoint
        p1 = Point((lastPoint.x + startPoint.x)/2, (lastPoint.y + startPoint.y)/2)
        p2 = lastPoint
        
        updateFormFromPoints()
    }
    
    func updateFormFromPoints() {
        var newPath: PathBuilder!
        
        newPath = MoveTo(x: p0.x, y: p0.y)
        
        for index in 1...100 {
            let t: Double = Double(index)/100
            let x = pow((1.0-t), 2.0)*p0.x + 2*(1.0-t)*t*p1.x + pow(t, 2.0)*p2.x
            let y = pow((1.0-t), 2.0)*p0.y + 2*(1.0-t)*t*p1.y + pow(t, 2.0)*p2.y
            
            newPath = newPath.lineTo(x: x, y: y)
        }
        
        drawing.form = newPath.build()
        backgroundDrawing.form = newPath.build()
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle2.form = Circle(cx: p2.x, cy: p2.y, r: 15)
        anchor0.form = Rect(x: p0.x-4, y: p0.y-4, w: 8, h: 8)
        anchor1.form = Rect(x: p1.x-4, y: p1.y-4, w: 8, h: 8)
        anchor2.form = Rect(x: p2.x-4, y: p2.y-4, w: 8, h: 8)
        line1.form = Line(x1: p0.x, y1: p0.y, x2: p1.x, y2: p1.y)
        line2.form = Line(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y)
        idText.place = .move(dx: p2.x+5, dy: p2.y)
    }
    
    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
        self.stroke = stroke
        idText.fill = self.stroke.fill
        drawing.stroke = stroke
    }
    
    func deleteShape() {
        contents = []
    }
    
    func redoShape() {
        contents = [drawing, backgroundDrawing]
        isActive = false
    }
    
    func getCenter() -> Point? {
        return p1
    }
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        p1 = Point(x: p1.x + dx, y: p1.y + dy)
        p2 = Point(x: p2.x + dx, y: p2.y + dy)
        updateFormFromPoints()
    }
}
