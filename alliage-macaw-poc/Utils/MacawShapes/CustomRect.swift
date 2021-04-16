//
//  CustomRect.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 06/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class CustomRect: Group, CustomShape {
    
    var annotationId: Int!
    var id: Int!
    var type: Annotation.Types!
    var comment: String = ""
    
    weak var delegate: MacawViewDelegate?
    var stroke: Stroke!
    
    var idText: Text!
    
    var p0: Point!
    var p1: Point!
    var p2: Point!
    var p3: Point!
    
    var circle0: Shape!
    var circle1: Shape!
    var circle2: Shape!
    var circle3: Shape!
    
    var circle01: Shape!
    var circle02: Shape!
    var circle23: Shape!
    var circle13: Shape!
    
    var anchor0: Shape!
    var anchor1: Shape!
    var anchor2: Shape!
    var anchor3: Shape!
    
    var anchor01: Shape!
    var anchor02: Shape!
    var anchor23: Shape!
    var anchor13: Shape!
    
    var rect: Shape!
    
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
    
    deinit {
        print("deinit shape")
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke, type: Annotation.Types, id: Int? = nil, annotationId: Int, comment: String) {
        super.init()
        
        self.stroke = stroke
        self.type = type
        self.id = id
        self.annotationId = annotationId
        self.comment = comment
        updatePoints(startPoint: startPoint, lastPoint: lastPoint)
        
        rect = Shape(form: Rect(), fill: Color.clear, stroke: stroke)

        circle0 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle1 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle2 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle3 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        
        circle01 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle02 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle23 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle13 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        
        anchor0 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor1 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor2 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor3 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor01 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor02 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor23 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor13 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill
        
        activeContents = [rect, anchor0, anchor1, anchor2, anchor3, anchor01, anchor02, anchor13, anchor23, idText, circle0, circle1, circle2, circle3, circle01, circle02, circle23, circle13]
        inactiveContents = [rect]
        
        contents = activeContents
        
        updateFormFromPoints()
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        updatePoints(startPoint: startPoint, lastPoint: lastPoint)
        updateFormFromPoints()
    }
    
    func setTransformEvents() {
        circle0.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP0 = Point(x: loc.x, y: loc.y)
            self?.p0 = newP0
            self?.p1 = Point(x: (self?.p1.x)!, y: (self?.p0.y)!)
            self?.p2 = Point(x: (self?.p0.x)!, y: (self?.p2.y)!)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle1.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP1 = Point(x: loc.x, y: loc.y)
            self?.p1 = newP1
            self?.p0 = Point(x: (self?.p0.x)!, y: (self?.p1.y)!)
            self?.p3 = Point(x: (self?.p1.x)!, y: (self?.p3.y)!)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle2.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP2 = Point(x: loc.x, y: loc.y)
            self?.p2 = newP2
            self?.p0 = Point(x: (self?.p2.x)!, y: (self?.p0.y)!)
            self?.p3 = Point(x: (self?.p3.x)!, y: (self?.p2.y)!)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle3.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP3 = Point(x: loc.x, y: loc.y)
            self?.p3 = newP3
            self?.p1 = Point(x: (self?.p3.x)!, y: (self?.p1.y)!)
            self?.p2 = Point(x: (self?.p2.x)!, y: (self?.p3.y)!)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle01.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP01 = Point(x: loc.x, y: loc.y)
            self?.p0 = Point(x: (self?.p0.x)!, y: newP01.y)
            self?.p1 = Point(x: (self?.p1.x)!, y: newP01.y)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle02.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP02 = Point(x: loc.x, y: loc.y)
            self?.p0 = Point(x: newP02.x, y: (self?.p0.y)!)
            self?.p2 = Point(x: newP02.x, y: (self?.p2.y)!)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle13.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP13 = Point(x: loc.x, y: loc.y)
            self?.p1 = Point(x: newP13.x, y: (self?.p1.y)!)
            self?.p3 = Point(x: newP13.x, y: (self?.p3.y)!)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle23.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP23 = Point(x: loc.x, y: loc.y)
            self?.p2 = Point(x: (self?.p2.x)!, y: newP23.y)
            self?.p3 = Point(x: (self?.p3.x)!, y: newP23.y)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        rect.onPan { [weak self] (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            if !(self?.isActive)! { return }
            self?.delegate?.activateScrollView(enable: false)
            self?.move(dx: event.dx, dy: event.dy)
            self?.delegate?.activateScrollView(enable: true)
        }
    }
    
    func updateFormFromPoints() {
        
        let width = p3.x - p0.x
        let height = p3.y - p0.y
        
        rect.form = Rect(x: p0.x, y: p0.y, w: width, h: height)
        
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle2.form = Circle(cx: p2.x, cy: p2.y, r: 15)
        circle3.form = Circle(cx: p3.x, cy: p3.y, r: 15)
        
        circle01.form = Circle(cx: (p0.x + p1.x)/2, cy: p0.y, r: 15)
        circle02.form = Circle(cx: p0.x, cy: (p0.y + p2.y)/2, r: 15)
        circle23.form = Circle(cx: (p2.x + p3.x)/2, cy: p2.y, r: 15)
        circle13.form = Circle(cx: p1.x, cy: (p1.y + p3.y)/2, r: 15)
        
        anchor0.form = Rect(x: p0.x-4, y: p0.y-4, w: 8, h: 8)
        anchor1.form = Rect(x: p1.x-4, y: p1.y-4, w: 8, h: 8)
        anchor2.form = Rect(x: p2.x-4, y: p2.y-4, w: 8, h: 8)
        anchor3.form = Rect(x: p3.x-4, y: p3.y-4, w: 8, h: 8)
        anchor01.form = Rect(x: ((p0.x + p1.x)/2)-4, y: p0.y-4, w: 8, h: 8)
        anchor02.form = Rect(x: p0.x-4, y: ((p0.y + p2.y)/2)-4, w: 8, h: 8)
        anchor23.form = Rect(x: ((p2.x + p3.x)/2)-4, y: p2.y-4, w: 8, h: 8)
        anchor13.form = Rect(x: p1.x-4, y: ((p1.y + p3.y)/2)-4, w: 8, h: 8)
        
        if p0.y < p2.y {
            idText.place = .move(dx: (p0.x + p1.x)/2, dy: p0.y-20)
        } else {
            idText.place = .move(dx: (p2.x + p3.x)/2, dy: p2.y-20)
        }
    }
    
    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
        self.stroke = stroke
        idText.fill = self.stroke.fill
        rect.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return rect.bounds?.center()
    }

    func updatePoints(startPoint: Point, lastPoint: Point) {
        p0 = startPoint
        p3 = lastPoint
        p1 = Point(x: p3.x, y: p0.y)
        p2 = Point(x: p0.x, y: p3.y)
    }
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        p1 = Point(x: p1.x + dx, y: p1.y + dy)
        p2 = Point(x: p2.x + dx, y: p2.y + dy)
        p3 = Point(x: p3.x + dx, y: p3.y + dy)
        updateFormFromPoints()
    }
}
