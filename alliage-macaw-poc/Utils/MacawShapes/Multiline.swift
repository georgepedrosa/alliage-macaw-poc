//
//  Multiline.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 22/07/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class Multiline: Group, CustomShape {
    
    var annotationId: Int!
    var id: Int!
    var type: Annotation.Types!
    var comment: String = ""
    weak var delegate: MacawViewDelegate?
    var drawing: Shape!
    var backgroundDrawing: Shape!
    var points: [Point] = []
    var texts: Group!//[Text] = []
    var lastText: Text = Text(text: "")
    var anchors: Group!
    var circles: Group!
    var idText: Text!
    
    var totalDistance: Double = 0.0
    var pixelsPerMilimeter: Double!
    
    var coordinateSystem: CoordinateSystem!
    
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
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke, coordinateSystem: CoordinateSystem, pixelsPerMilimeter: Double, type: Annotation.Types, id: Int? = nil, annotationId: Int) {
        super.init()
        
        self.stroke = stroke
        self.points.append(startPoint)
        self.coordinateSystem = coordinateSystem
        self.pixelsPerMilimeter = pixelsPerMilimeter
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
        texts = Group(contents: [])
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
                cap: .square
            )
        )
        
        backgroundDrawing  = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: Color.clear,
                width: 30,
                cap: .square
            )
        )
        
        lastText.fill = stroke.fill
//        contents = [drawing, lastText, backgroundDrawing, anchors, idText, circles]
        activeContents = [drawing, lastText, texts, backgroundDrawing, anchors, idText, circles]
        inactiveContents = [drawing, lastText, texts, backgroundDrawing]
    
    }
    
    init(points: [Point], stroke: Stroke, coordinateSystem: CoordinateSystem, pixelsPerMilimeter: Double, type: Annotation.Types, id: Int? = nil, annotationId: Int, comment: String) {
        super.init()
        
        self.stroke = stroke
        self.points = points
        self.coordinateSystem = coordinateSystem
        self.pixelsPerMilimeter = pixelsPerMilimeter
        self.type = type
        self.id = id
        self.annotationId = annotationId
        self.comment = comment
        
        anchors = Group(contents: [])
        circles = Group(contents: [])
        texts = Group(contents: [])
        
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill
        
        var path: PathBuilder = MoveTo(x: points[0].x, y: points[0].y)
        path = path.lineTo(x: points[0].x + 1, y: points[0].y + 1)
        
        drawing = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: stroke.fill,
                width: stroke.width,
                cap: .square
            )
        )
        
        backgroundDrawing  = Shape(
            form: path.build(),
            stroke: Stroke(
                fill: Color.clear,
                width: 30,
                cap: .square
            )
        )
        
        lastText.fill = stroke.fill
        
        activeContents = [drawing, lastText, texts, backgroundDrawing, anchors, idText, circles]
        inactiveContents = [drawing, lastText, texts, backgroundDrawing]
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
        backgroundDrawing.form = path.build()
        
        if points.count > 1 {
            let middleX = (points[points.count-1].x + points[points.count-2].x)/2
            let middleY = (points[points.count-1].y + points[points.count-2].y)/2
            let middlePoint = Point(middleX, middleY)
            
            let d = distance(points[points.count-2], points[points.count-1], scaled: true)
            totalDistance += d
            
            let textNode = Text(text: String(format: "%.2f", d/pixelsPerMilimeter) + " mm")
            textNode.place = .move(dx: middlePoint.x+10, dy: middlePoint.y+10)
            textNode.fill = self.stroke.fill
            
            texts.contents.append(textNode)
            self.contents.append(textNode)
            
            lastText.text = String(format: "%.2f", totalDistance/pixelsPerMilimeter) + " mm"
            lastText.place = .move(dx: points.last!.x+10, dy: points.last!.y+10)
        }
    }
    
    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
        self.stroke = stroke
        idText.fill = self.stroke.fill
        drawing.stroke = stroke
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
            
            if points.count > 1 && i > 0 {
                let middleX = (points[i].x + points[i-1].x)/2
                let middleY = (points[i].y + points[i-1].y)/2
                let middlePoint = Point(middleX, middleY)
                
                let d = distance(points[i-1], points[i], scaled: true)
                totalDistance += d
                
                if created {
                    let textNode = Text(text: String(format: "%.2f", d/pixelsPerMilimeter) + " mm")
                    textNode.place = .move(dx: middlePoint.x+10, dy: middlePoint.y+10)
                    textNode.fill = self.stroke.fill
                    texts.contents.append(textNode)
                    self.contents.append(textNode)
                } else {
                    let text = texts.contents[i-1] as! Text
                    text.text = String(format: "%.2f", d/pixelsPerMilimeter) + " mm"
                    text.place = .move(dx: middlePoint.x+10, dy: middlePoint.y+10)
                }
            }
        }
        
        lastText.text = String(format: "%.2f", totalDistance/pixelsPerMilimeter) + " mm"
        lastText.place = .move(dx: points.last!.x+10, dy: points.last!.y+10)

        drawing.form = path.build()
        backgroundDrawing.form = path.build()
        idText.place = .move(dx: points[0].x+10, dy: points[0].y)
    }
    
    func move(dx: Double, dy: Double) {
        for i in 0..<points.count {
            points[i] = Point(x: points[i].x + dx, y: points[i].y + dy)
        }
        updateFormFromPoints()
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
    
    func getScaledPoint(x: Double, y: Double) -> Point {
        let newX = (x * coordinateSystem.imageWidth)/coordinateSystem.frameWidth
        let newY = (y * coordinateSystem.imageHeight)/coordinateSystem.frameHeight
        return Point(newX, newY)
    }
    
    func updateCalibration(pixelsPerMilimeter: Double) {
        self.pixelsPerMilimeter = pixelsPerMilimeter
        totalDistance = 0
        for i in 0..<points.count {
            if points.count > 1 && i > 0 {
                let d = distance(points[i-1], points[i], scaled: true)
                totalDistance += d
                
                let text = texts.contents[i-1] as! Text
                text.text = String(format: "%.2f", d/pixelsPerMilimeter) + " mm"
            }
        }
        lastText.text = String(format: "%.2f", totalDistance/pixelsPerMilimeter) + " mm"
    }
}
