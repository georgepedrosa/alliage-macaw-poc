//
//  Calibration.swift
//  Alliage
//
//  Created by George Pedrosa on 20/09/19.
//  Copyright © 2019 LDS. All rights reserved.
//

import UIKit
import Macaw

protocol CalibrationDelegate: class {
    func measurePixels(_ d: Double)
}

class CustomCalibration: Group, CustomShape {
    
    var annotationId: Int!
    var id: Int!
    var type: Annotation.Types!
    var comment: String = ""
    
    weak var calibrationDelegate: CalibrationDelegate?
    
    let headAngle = Double.pi/2
    
    var coordinateSystem: CoordinateSystem!
    
    weak var delegate: MacawViewDelegate?
    var stroke: Stroke!
    
    var p0: Point!
    var p1: Point!
    
    var line: Shape!
    var headLeft: Shape!
    var headRight: Shape!
    var headLeft2: Shape!
    var headRight2: Shape!
    
    var backgroundLine: Shape!
    var backgroundHeadLeft: Shape!
    var backgroundHeadRight: Shape!
    var backgroundHeadLeft2: Shape!
    var backgroundHeadRight2: Shape!
    
    var circle0: Shape!
    var circle1: Shape!
    
    var anchor0: Shape!
    var anchor1: Shape!
    
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
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke, calibrationDelegate: CalibrationDelegate, coordinateSystem: CoordinateSystem, type: Annotation.Types, annotationId: Int, comment: String) {
        super.init()
        
        self.stroke = stroke
        self.calibrationDelegate = calibrationDelegate
        self.coordinateSystem = coordinateSystem
        self.type = type
        self.annotationId = annotationId
        self.comment = comment
        
        p0 = startPoint
        p1 = lastPoint
        
        line = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: stroke.fill, width: stroke.width))
        backgroundLine = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        headLeft = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: stroke.fill, width: stroke.width, cap: .round, join: .round))
        backgroundHeadLeft = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        headRight = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: stroke.fill, width: stroke.width, cap: .round, join: .round))
        backgroundHeadRight = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        headLeft2 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: stroke.fill, width: stroke.width, cap: .round, join: .round))
        backgroundHeadLeft2 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        headRight2 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: stroke.fill, width: stroke.width, cap: .round, join: .round))
        backgroundHeadRight2 = Shape(form: Line(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        circle0 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        circle1 = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        anchor0 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        anchor1 = Shape(form: Rect(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
        
        activeContents = [line, backgroundLine, headLeft, backgroundHeadLeft, headRight, backgroundHeadRight, headLeft2, backgroundHeadLeft2, headRight2, backgroundHeadRight2, anchor0, anchor1, circle0, circle1]
        inactiveContents = [line, backgroundLine, headLeft, backgroundHeadLeft, headRight, backgroundHeadRight, headLeft2, backgroundHeadLeft2, headRight2, backgroundHeadRight2]
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
            self?.calibrationDelegate?.measurePixels(self!.distance(self!.p0, self!.p1, scaled: true))
        }
        
        circle1.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            let newP1 = Point(x: loc.x, y: loc.y)
            self?.p1 = newP1
            self?.updateFormFromPoints()
            self?.calibrationDelegate?.measurePixels(self!.distance(self!.p0, self!.p1, scaled: true))
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
        let l2 = stroke.width*3
        
        let x3 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(headAngle) ) + ( (y1-y2) * (sin(headAngle) ) ) ) )
        let y3 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(headAngle) ) - ( (x1-x2) * (sin(headAngle) ) ) ) )
        let x4 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(headAngle) ) - ( (y1-y2) * (sin(headAngle) ) ) ) )
        let y4 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(headAngle) ) + ( (x1-x2) * (sin(headAngle) ) ) ) )
        
        let x5 = x1 + ( (l2/l1) * ( ( (x2-x1) * cos(headAngle) ) + ( (y2-y1) * (sin(headAngle) ) ) ) )
        let y5 = y1 + ( (l2/l1) * ( ( (y2-y1) * cos(headAngle) ) - ( (x2-x1) * (sin(headAngle) ) ) ) )
        let x6 = x1 + ( (l2/l1) * ( ( (x2-x1) * cos(headAngle) ) - ( (y2-y1) * (sin(headAngle) ) ) ) )
        let y6 = y1 + ( (l2/l1) * ( ( (y2-y1) * cos(headAngle) ) + ( (x2-x1) * (sin(headAngle) ) ) ) )
        
        let headLeftLocus = Line(x1: x2, y1: y2, x2: x3, y2: y3)
        let headRightLocus = Line(x1: x2, y1: y2, x2: x4, y2: y4)
        
        let headLeftLocus2 = Line(x1: x1, y1: y1, x2: x5, y2: y5)
        let headRightLocus2 = Line(x1: x1, y1: y1, x2: x6, y2: y6)
        
        line.form = Line(p0.x, p0.y, p1.x, p1.y)
        backgroundLine.form = Line(p0.x, p0.y, p1.x, p1.y)
        headLeft.form = headLeftLocus
        backgroundHeadLeft.form = headLeftLocus
        headRight.form = headRightLocus
        backgroundHeadRight.form = headRightLocus
        headLeft2.form = headLeftLocus2
        backgroundHeadLeft2.form = headLeftLocus2
        headRight2.form = headRightLocus2
        backgroundHeadRight2.form = headRightLocus2
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 20)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 20)
        anchor0.form = Rect(x: p0.x-4, y: p0.y-4, w: 8, h: 8)
        anchor1.form = Rect(x: p1.x-4, y: p1.y-4, w: 8, h: 8)
    }
    
    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
        self.stroke = stroke
        line.stroke = stroke
        headLeft.stroke = stroke
        headRight.stroke = stroke
        headLeft2.stroke = stroke
        headRight2.stroke = stroke    }
    
    func getCenter() -> Point? {
        return line.bounds?.center()
    }
    
    func distance(_ a: Point, _ b: Point, scaled: Bool = false) -> Double {
        
        if a == b { return 0.0001 }
        
        var newA = a
        var newB = b
        
        if scaled {
            newA = getScaledPoint(x: a.x, y: a.y)
            newB = getScaledPoint(x: b.x, y: b.y)
        }
        
        let xDist = newA.x - newB.x
        let yDist = newA.y - newB.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        p1 = Point(x: p1.x + dx, y: p1.y + dy)
        updateFormFromPoints()
    }
    
    func getScaledPoint(x: Double, y: Double) -> Point {
        let newX = (x * coordinateSystem.imageWidth)/coordinateSystem.frameWidth
        let newY = (y * coordinateSystem.imageHeight)/coordinateSystem.frameHeight
        return Point(newX, newY)
    }
}
