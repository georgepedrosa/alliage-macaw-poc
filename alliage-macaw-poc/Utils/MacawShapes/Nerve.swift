//
//  Nerve.swift
//  Alliage
//
//  Created by George Pedrosa on 19/09/19.
//  Copyright © 2019 LDS. All rights reserved.
//

import UIKit
import Macaw

class Nerve: Group, CustomShape {
    
    var annotationId: Int!
    var id: Int!
    var type: Annotation.Types!
    var comment: String = ""
    weak var delegate: MacawViewDelegate?
    var drawing: Shape!
    var outerDrawing: Shape!
    var backgroundDrawing: Shape!
    var points: [Point] = []
    var anchors: Group!
    var circles: Group!
    var idText: Text!
    
    var totalDistance: Double = 0.0
    
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
    
    var stroke: Stroke!
    var outerStroke: Stroke!
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke, outerStroke: Stroke, type: Annotation.Types, id: Int? = nil, annotationId: Int) {
        super.init()
        
        self.stroke = stroke
        self.outerStroke = outerStroke
        self.points.append(startPoint)
        self.type = type
        self.id = id
        self.annotationId = annotationId
        
        let locusAnchor = Rect(x: startPoint.x-4, y: startPoint.y-4, w: 8, h: 8)
        let locusCircle = Circle(cx: startPoint.x, cy: startPoint.y, r: 20)
        let anchor = Shape(form: locusAnchor, fill: Color.white, stroke: Stroke(fill: Color.black, width: 1))
        let circle = Shape(form: locusCircle, stroke: Stroke(fill: Color.clear, width: 5))
        setNewCircleEvent(circle: circle, index: 0)
        anchors = Group(contents: [anchor])
        circles = Group(contents: [circle])
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill
        idText.place = .move(dx: points[0].x, dy: points[0].y)
        
        var path: PathBuilder = MoveTo(x: startPoint.x, y: startPoint.y)
        path = path.lineTo(x: startPoint.x + 1, y: startPoint.y + 1)

        drawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: stroke.fill,
                width: stroke.width,
                cap: .round,
                join: .round
            )
        )
        
        outerDrawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: outerStroke.fill,
                width: outerStroke.width,
                cap: .round,
                join: .round
            )
        )
        
        backgroundDrawing  = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: Color.clear,
                width: 30,
                cap: .round,
                join: .round
            )
        )
        activeContents = [outerDrawing, drawing, backgroundDrawing, anchors, idText, circles]
        inactiveContents = [outerDrawing, drawing, backgroundDrawing]
//        contents = [outerDrawing, drawing, backgroundDrawing, anchors, circles]
        
    }
    
    init(points: [Point], stroke: Stroke, outerStroke: Stroke, type: Annotation.Types, id: Int? = nil, annotationId: Int, comment: String) {
        super.init()
        
        self.stroke = stroke
        self.outerStroke = outerStroke
        self.points = points
        self.type = type
        self.id = id
        self.annotationId = annotationId
        self.comment = comment
        
        anchors = Group(contents: [])
        circles = Group(contents: [])
        
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill
        
        var path: PathBuilder = MoveTo(x: points[0].x, y: points[0].y)
        path = path.lineTo(x: points[0].x + 1, y: points[0].y + 1)
        
        drawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: stroke.fill,
                width: stroke.width,
                cap: .round,
                join: .round
            )
        )
        
        outerDrawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: outerStroke.fill,
                width: outerStroke.width,
                cap: .round,
                join: .round
            )
        )
        
        backgroundDrawing  = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: Color.clear,
                width: 30,
                cap: .round,
                join: .round
            )
        )
        
        activeContents = [outerDrawing, drawing, backgroundDrawing, anchors, idText, circles]
        inactiveContents = [outerDrawing, drawing, backgroundDrawing]
        contents = activeContents
        updateFormFromPoints(created: true)
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        
    }
    
    func newPoint(point: Point) {
        points.append(point)
        
        if points.count == 2 {
            contents = activeContents
        }
        
        let locusAnchor = Rect(x: point.x-4, y: point.y-4, w: 8, h: 8)
        let anchor = Shape(form: locusAnchor, fill: Color.white, stroke: Stroke(fill: Color.black, width: 1))
        anchors.contents.append(anchor)
        
        circles.contents.removeAll()
        
        for point in points {
            let locusCircle = Circle(cx: point.x, cy: point.y, r: 20)
            
            let circle = Shape(form: locusCircle, fill: Color.clear,  stroke: Stroke(fill: Color.clear, width: 5))
            setNewCircleEvent(circle: circle, index: circles.contents.count)
            circles.contents.append(circle)
        }
        
        var path: PathBuilder = MoveTo(x: points[0].x, y: points[0].y)
        for point in points {
            path = path.lineTo(x: point.x, y: point.y)
        }
        
        drawing.form = path.build()
        outerDrawing.form = path.build()
        backgroundDrawing.form = path.build()
    }
    
    func updateStroke(stroke: Stroke, stroke2: Stroke? = nil) {
        self.stroke = Stroke(fill: stroke.fill, width: stroke.width, cap: .round, join: .round)

        drawing.stroke = self.stroke 
        idText.fill = self.stroke.fill
        if let newStroke = stroke2 {
            self.outerStroke = newStroke
            outerDrawing.stroke = Stroke(fill: newStroke.fill, width: newStroke.width, cap: .round, join: .round)
        }
    }
    
    func getCenter() -> Point? {
        return Point()
    }
    
    func setTransformEvents() {
        backgroundDrawing.onPan { [weak self] (event) in
            guard let _ = event.node else { print("problem on pan")
                return
            }
            if !self!.isActive { return }
            self?.delegate?.activateScrollView(enable: false)
            self?.move(dx: event.dx, dy: event.dy)
            self?.delegate?.activateScrollView(enable: true)
        }
    }
    
    func setNewCircleEvent(circle: Shape, index: Int) {
        circle.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            //let transform = self.delegate.shapeTransformations[self.hash]
            let newPoint = Point(x: loc.x, y: loc.y)
            self?.points[index] = newPoint
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
    }
    
    func updateFormFromPoints(created: Bool = false) {
        
        var path: PathBuilder = MoveTo(x: points[0].x, y: points[0].y)
        
        totalDistance = 0.0
        
        for i in 0..<points.count {
            path = path.lineTo(x: points[i].x, y: points[i].y)
            
            if created {
                let locusAnchor = Rect(x: points[i].x-4, y: points[i].y-4, w: 8, h: 8)
                let anchor = Shape(form: locusAnchor, fill: Color.white, stroke: Stroke(fill: Color.black, width: 1))
                anchors.contents.append(anchor)
                
                let locusCircle = Circle(cx: points[i].x, cy: points[i].y, r: 20)
                let circle = Shape(form: locusCircle, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5))
                setNewCircleEvent(circle: circle, index: i)
                circles.contents.append(circle)
            } else {
                let anchor = anchors.contents[i] as! Shape
                anchor.form = Rect(x: points[i].x-4, y: points[i].y-4, w: 8, h: 8)
                
                let circle = circles.contents[i] as! Shape
                circle.form = Circle(cx: points[i].x, cy: points[i].y, r: 20)
            }
        }

        drawing.form = path.build()
        outerDrawing.form = path.build()
        backgroundDrawing.form = path.build()
        idText.place = .move(dx: points[0].x+10, dy: points[0].y)
    }
    
    func move(dx: Double, dy: Double) {
        for i in 0..<points.count {
            points[i] = Point(x: points[i].x + dx, y: points[i].y + dy)
        }
        updateFormFromPoints()
    }
    
    func distance(_ a: Point, _ b: Point) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func getScaledPoint(x: Double, y: Double) -> Point {
        return Point(x,y)
        //        let newX = (x * coordinateSystem.imageWidth)/coordinateSystem.frameWidth
        //        let newY = (y * coordinateSystem.imageHeight)/coordinateSystem.frameHeight
        //        return Point(newX, newY)
    }
}
