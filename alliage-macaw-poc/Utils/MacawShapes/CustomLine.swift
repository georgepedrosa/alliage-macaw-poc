//
//  Line.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 06/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class CustomLine: Group, CustomShape {
    
    var annotationId: Int!
    var id: Int!
    var type: Annotation.Types!
    var comment: String = ""
    
    var line: Shape!
    var circle0: Shape!
    var circle1: Shape!
    var anchor0: Shape!
    var anchor1: Shape!
    var backgroundLine: Shape!
    
    var idText: Text!
    
    var p0: Point!
    var p1: Point!
    
    var radius: Double = 20
    
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
    
    weak var delegate: MacawViewDelegate?
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke, type: Annotation.Types, id: Int? = nil, annotationId: Int, comment: String) {
        super.init()
        
        self.stroke = stroke
        self.type = type
        self.p0 = startPoint
        self.p1 = lastPoint
        self.id = id
        self.annotationId = annotationId
        self.comment = comment
                
        line = Shape(form: Line(), fill: Color.clear, stroke: stroke)
        backgroundLine = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        circle0 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle1 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        anchor0 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor1 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill
        
        activeContents = [line, idText, backgroundLine, anchor0, anchor1, circle0, circle1]
        inactiveContents = [line, backgroundLine]
        contents = activeContents
        updateFormFromPoints()
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        p0 = startPoint
        p1 = lastPoint
        updateFormFromPoints()
    }
    
    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
        self.stroke = stroke
        line.stroke = stroke
        idText.fill = self.stroke.fill
    }
    
    func getCenter() -> Point? {
        return line.bounds?.center()
    }

    func setTransformEvents() {
        circle0.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            //let transform = self.delegate.shapeTransformations[self.hash]
            let newP0 = Point(x: loc.x, y: loc.y)
            
            self?.p0 = newP0
            self?.updateFormFromPoints()
        }
        
        circle1.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            //let transform = self.delegate.shapeTransformations[self.hash]
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
        line.form = Line(p0.x, p0.y, p1.x, p1.y)
        backgroundLine.form = Line(p0.x, p0.y, p1.x, p1.y)
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: radius)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: radius)
        anchor0.form = Rect(x: p0.x-4, y: p0.y-4, w: 8, h: 8)
        anchor1.form = Rect(x: p1.x-4, y: p1.y-4, w: 8, h: 8)
        idText.place = .move(dx: p0.x, dy: p0.y - 20)
    }
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        p1 = Point(x: p1.x + dx, y: p1.y + dy)
        updateFormFromPoints()
    }
}
