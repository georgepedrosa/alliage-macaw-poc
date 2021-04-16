//
//  Asterisk.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 05/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class Asterisk: Group, CustomShape {
    
    var annotationId: Int!
    var id: Int!
    var type: Annotation.Types!
    var comment: String = ""
    
    weak var delegate: MacawViewDelegate?
    var stroke: Stroke!
    
    var p0: Point!
    var p1: Point!
    var p2: Point!
    var p3: Point!
    var p4: Point!
    var p5: Point!
    var p6: Point!
    var p7: Point!
    var p8: Point!
    
    var line1: Shape!
    var line2: Shape!
    var line3: Shape!
    var line4: Shape!
    
    var backgroundCircle: Shape!
    
    var backgroundLine1: Shape!
    var backgroundLine2: Shape!
    var backgroundLine3: Shape!
    var backgroundLine4: Shape!
    
    var backgroundRect: Shape!
    
    var idText: Text!
    
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

        p0 = Point(x: startPoint.x, y: startPoint.y)
        
        line1 = Shape(form: Line(), fill: Color.clear, stroke: stroke)
        backgroundLine1 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        line2 = Shape(form: Line(), fill: Color.clear, stroke: stroke)
        backgroundLine2 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        line3 = Shape(form: Line(), fill: Color.clear, stroke: stroke)
        backgroundLine3 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        line4 = Shape(form: Line(), fill: Color.clear, stroke: stroke)
        backgroundLine4 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        backgroundCircle = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 1.0))
        
        backgroundRect = Shape(form: Rect(), fill: Color.clear, stroke: Stroke(fill: Color.white, width: 2, dashes: [2, 2]))
        
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill

        activeContents = [idText, line1, backgroundLine1, line2, backgroundLine2, line3, backgroundLine3, line4, backgroundLine4, backgroundRect, backgroundCircle]
        inactiveContents = [line1, backgroundLine1, line2, backgroundLine2, line3, backgroundLine3, line4, backgroundLine4, backgroundCircle]
        contents = activeContents
        
        updateFormFromPoints()
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
    }
    
    func updateFormFromPoints() {
        let x1 = p0.x
        let y1 = p0.y
        
        let x2 = x1 + 10
        let y2 = y1 + 10
        
        p1 = Point(x2, y2)
        
        let cx = (x1+x2)/2
        let cy = (y1+y2)/2
        
        p8 = Point(cx, cy)
        
        let x3 = (  (x1 - cx) * cos(0.78) + (y1 - cy) * sin(0.78) ) + cx
        let y3 = ( -(x1 - cx) * sin(0.78) + (y1 - cy) * cos(0.78) ) + cy
        
        p2 = Point(x3, y3)
        
        let x4 = (  (x2 - cx) * cos(0.78) + (y2 - cy) * sin(0.78) ) + cx
        let y4 = ( -(x2 - cx) * sin(0.78) + (y2 - cy) * cos(0.78) ) + cy
        
        p3 = Point(x4, y4)
        
        let x5 = (  (x1 - cx) * cos(1.57) + (y1 - cy) * sin(1.57) ) + cx
        let y5 = ( -(x1 - cx) * sin(1.57) + (y1 - cy) * cos(1.57) ) + cy
        
        p4 = Point(x5, y5)
        
        let x6 = (  (x2 - cx) * cos(1.57) + (y2 - cy) * sin(1.57) ) + cx
        let y6 = ( -(x2 - cx) * sin(1.57) + (y2 - cy) * cos(1.57) ) + cy
        
        p5 = Point(x6, y6)
        
        let x7 = (  (x1 - cx) * cos(2.36) + (y1 - cy) * sin(2.36) ) + cx
        let y7 = ( -(x1 - cx) * sin(2.36) + (y1 - cy) * cos(2.36) ) + cy
        
        p6 = Point(x7, y7)
        
        let x8 = (  (x2 - cx) * cos(2.36) + (y2 - cy) * sin(2.36) ) + cx
        let y8 = ( -(x2 - cx) * sin(2.36) + (y2 - cy) * cos(2.36) ) + cy
        
        p7 = Point(x8, y8)
        
        line1.form = Line(x1, y1, x2, y2)
        backgroundLine1.form = Line(x1, y1, x2, y2)
        line2.form = Line(x3, y3, x4, y4)
        backgroundLine2.form = Line(x3, y3, x4, y4)
        line3.form = Line(x5, y5, x6, y6)
        backgroundLine3.form = Line(x5, y5, x6, y6)
        line4.form = Line(x7, y7, x8, y8)
        backgroundLine4.form = Line(x7, y7, x8, y8)
        
        backgroundCircle.form = Circle(cx: cx, cy: cy, r: 15)
        
        idText.place = .move(dx: p0.x, dy: p0.y - 20)
        
        let group = Group(contents: [line1, line2, line3, line4])
        backgroundRect.form = group.bounds!
    }
    
    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
        self.stroke = stroke
        line1.stroke = stroke
        line2.stroke = stroke
        line3.stroke = stroke
        line4.stroke = stroke
        idText.fill = self.stroke.fill
    }
    
    func getCenter() -> Point? {
        return line1.bounds?.center()
    }
    
    func setTransformEvents() {
        backgroundRect.onPan { [weak self] (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            if !self!.isActive { return }
            self?.delegate?.activateScrollView(enable: false)
            self?.move(dx: event.dx, dy: event.dy)
            self?.delegate?.activateScrollView(enable: true)
        }
    }
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        updateFormFromPoints()
    }
}
