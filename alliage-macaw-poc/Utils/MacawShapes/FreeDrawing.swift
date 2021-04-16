//
//  FreeDrawing.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 07/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class FreeDrawing: Group, CustomShape {
    
    var annotationId: Int!
    var id: Int!
    var type: Annotation.Types!
    var comment: String = ""
    weak var delegate: MacawViewDelegate?
    var stroke: Stroke!
    
    var drawing: Shape!
    var backgroundDrawing: Shape!
    var path: PathBuilder!
    var backgroundRect: Shape!
    
    var idText: Text!
    
    var points: [Point]!
    
    var activeContents: [Node]!
    var inactiveContents: [Node]!
    
    var isActive: Bool = false {
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
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke, type: Annotation.Types, id: Int? = nil, annotationId: Int) {
        super.init()
        self.stroke = stroke
        self.type = type
        self.id = id
        self.annotationId = annotationId
        
        points = [startPoint]
        
        path = MoveTo(x: startPoint.x, y: startPoint.y)
        path = path.lineTo(x: startPoint.x, y: startPoint.y)
        
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
        
        backgroundRect = Shape(form: drawing.form.bounds(), fill: Color.clear, stroke: Stroke(fill: Color.white, width: 2, dashes: [5, 5]))
        
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill
        
        activeContents = [drawing, backgroundDrawing, backgroundRect]
        inactiveContents = [drawing, backgroundDrawing]
        contents = inactiveContents
        
        idText.place = .move(dx: drawing.form.bounds().x, dy: drawing.form.bounds().y-20)
        activeContents.append(idText)
    }
    
    init(startPoint: Point, middlePoints: [Point], lastPoint: Point, stroke: Stroke, type: Annotation.Types, id: Int? = nil, annotationId: Int, comment: String) {
        super.init()
        self.stroke = stroke
        self.type = type
        self.id = id
        self.annotationId = annotationId
        self.comment = comment
        
        points = []
        
        points.append(startPoint)
        points.append(contentsOf: middlePoints)
        points.append(lastPoint)
        
        path = MoveTo(x: startPoint.x, y: startPoint.y)
        path = path.lineTo(x: startPoint.x, y: startPoint.y)
        
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
        
        backgroundRect = Shape(form: drawing.form.bounds(), fill: Color.clear, stroke: Stroke(fill: Color.white, width: 2, dashes: [5, 5]))
        
        idText = Text(text: String(annotationId))
        idText.fill = self.stroke.fill
        
        activeContents = [drawing, backgroundDrawing, backgroundRect, idText]
        inactiveContents = [drawing, backgroundDrawing]
        contents = activeContents
        
        updateFormFromPoints()
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        points.append(lastPoint)
        path = path.lineTo(x: lastPoint.x, y: lastPoint.y)
        drawing.form = path.build()
        backgroundDrawing.form = path.build()
        backgroundRect.form = drawing.form.bounds()
        idText.place = .move(dx: drawing.form.bounds().x, dy: drawing.form.bounds().y-20)
    }
    
    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
        self.stroke = stroke
        drawing.stroke = stroke
        idText.fill = self.stroke.fill
    }
    
    func deleteShape() {
        contents = []
    }
    
    func redoShape() {
        contents = [drawing]
        isActive = false
    }
    
    func getCenter() -> Point? {
        return self.bounds?.center()
    }
    
    func setTransformEvents() {
        backgroundRect.onPan { [weak self] (event) in
            guard let _ = event.node else { print("problem on pan")
                return
            }
            if !self!.isActive { return }
            self?.delegate?.activateScrollView(enable: false)
            self?.move(dx: event.dx, dy: event.dy)
            self?.delegate?.activateScrollView(enable: true)
        }
    }
    
    func updateFormFromPoints() {
        path = MoveTo(x: points[0].x, y: points[0].y)
        for i in 1..<points.count {
            path = path.lineTo(x: points[i].x, y: points[i].y)
        }
        drawing.form = path.build()
        backgroundDrawing.form = path.build()
        backgroundRect.form = drawing.form.bounds()
        idText.place = .move(dx: drawing.form.bounds().x, dy: drawing.form.bounds().y-20)
    }
    
    func move(dx: Double, dy: Double) {
        for i in 0..<points.count {
            points[i] = Point(x: points[i].x + dx, y: points[i].y + dy)
        }
        updateFormFromPoints()
    }
}
