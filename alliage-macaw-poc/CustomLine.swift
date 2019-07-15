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
    
    var line: Shape!
    var circle: Shape!
    var circle2: Shape!
    var backgroundLine: Shape!
    
    var startPoint: Point!
    var lastPoint: Point!
    
    var radius: Double = 20
    
    var isActive: Bool = false {
        didSet {
            line.stroke = (isActive ? Stroke(fill: Color.blue, width: 5.0) : Stroke(fill: Color.red, width: 5.0))
        }
    }
    
    var delegate: MacawViewDelegate!
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        self.startPoint = startPoint
        self.lastPoint = lastPoint
        
        let circleStroke = Stroke(fill: Color.clear)
        
        let lineLocus = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        line = Shape(form: lineLocus, fill: Color.clear, stroke: stroke)
        backgroundLine = Shape(form: lineLocus, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let circleLocus = Circle(cx: lastPoint.x, cy: lastPoint.y, r: radius)
        circle = Shape(form: circleLocus, fill: Color.clear, stroke: circleStroke)
        
        let circleLocus2 = Circle(cx: startPoint.x, cy: startPoint.y, r: radius)
        circle2 = Shape(form: circleLocus2, fill: Color.clear, stroke: circleStroke)
        
        contents = [line, backgroundLine, circle, circle2]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        line.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        backgroundLine.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        circle.form = Circle(cx: lastPoint.x, cy: lastPoint.y, r: radius)
        circle2.form = Circle(cx: startPoint.x, cy: startPoint.y, r: radius)
        //self.startPoint = startPoint
        //self.lastPoint = lastPoint
    }
    
    func updateStroke(stroke: Stroke) {
        line.stroke = stroke
    }
    
    func updateCircleStroke(stroke: Stroke) {
        circle.stroke = stroke
        circle2.stroke = stroke
    }
    
    func updateSize(scale: Double) {
        let circleLocus = circle.form as! Circle
        let newLocus = Circle(cx: circleLocus.cx, cy: circleLocus.cy, r: radius/scale)
        circle.form = newLocus
        
        let circle2Locus = circle2.form as! Circle
        let newLocus2 = Circle(cx: circle2Locus.cx, cy: circle2Locus.cy, r: radius/scale)
        circle2.form = newLocus2
    }
    
    func getCenter() -> Point? {
        return line.bounds?.center()
    }
    
    func activateCircleAction() {
        
    }
    
    func setLineEvents() {
        var startPoint = Point()
        var lastPoint = Point(x: 0, y: 0)
        var tempLine: CustomLine!
        
        self.circle2.onTouchPressed { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let center = self.getCenter()
            lastPoint = Point(x: self.lastPoint.x - self.startPoint.x, y: self.lastPoint.y - self.startPoint.y)
            let lastPointAux = Shape(form: Point(x: 0, y: 0))
            lastPointAux.place = Transform.move(dx: transform!.dx + center!.x, dy:  transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y).move(dx: lastPoint.x, dy: lastPoint.y)
            lastPoint = Point(x: lastPointAux.place.dx, y: lastPointAux.place.dy)
            tempLine = CustomLine(startPoint: loc, lastPoint: lastPoint, stroke: self.delegate.stroke)
            tempLine.delegate = self.delegate
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == self.hash
            })
            self.delegate.shapesGroup.contents[index!] = tempLine
        }
        
        self.circle.onTouchPressed { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let pointAux = Shape(form: Point(x: 0, y: 0))
            let center = self.getCenter()
            pointAux.place = Transform.move(dx: transform!.dx + center!.x, dy: transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y)
            startPoint = Point(x: pointAux.place.dx, y: pointAux.place.dy)
            tempLine = CustomLine(startPoint: startPoint, lastPoint: loc, stroke: self.delegate.stroke)
            tempLine.delegate = self.delegate
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == self.hash
            })
            self.delegate.shapesGroup.contents[index!] = tempLine
        }
        
        self.circle2.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            tempLine.updateForm(startPoint: loc, lastPoint: tempLine.lastPoint)
        }
        
        self.circle.onTouchMoved({ (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            tempLine.updateForm(startPoint: tempLine.startPoint, lastPoint: loc)
        })
        
        self.circle2.onTouchReleased { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            let x = tempLine.lastPoint.x - loc.x
            let y = tempLine.lastPoint.y - loc.y
            let newLine = CustomLine(startPoint: Point(0, 0), lastPoint: Point(x: x, y: y), stroke: self.delegate.stroke)
            newLine.delegate = self.delegate
            newLine.place = Transform.move(dx: loc.x, dy: loc.y).scale(sx: 1, sy: 1)
            newLine.startPoint = loc
            newLine.lastPoint = tempLine.lastPoint
            self.delegate.shapeTransformations[newLine.hash] = (loc.x, loc.y, 1, 0)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == tempLine.hash
            })
            self.delegate.shapesGroup.contents[index!] = newLine
            newLine.setLineEvents()
            self.delegate.activateScrollView(enable: true)
        }
        
        self.circle.onTouchReleased { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            let newLine = CustomLine(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y), stroke: self.delegate.stroke)
            newLine.delegate = self.delegate
            //newLine.updateForm(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y))
            newLine.place = Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1, sy: 1)
            newLine.startPoint = startPoint
            newLine.lastPoint = loc
            self.delegate.shapeTransformations[newLine.hash] = (startPoint.x,startPoint.y, 1, 0)
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == tempLine.hash
            })
            self.delegate.shapesGroup.contents[index!] = newLine
            newLine.setLineEvents()
            self.delegate.activateScrollView(enable: true)
        }
        
        self.backgroundLine.onPan { (event) in
            guard let _ = event.node else { print("problem on line pan")
                return
            }
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
            self.delegate.activateScrollView(enable: true)
        }
        
        self.backgroundLine.onRotate { (event) in
            guard let _ = event.node else { print("problem on line rotate")
                return
            }
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx, transform!.dy, transform!.scale, transform!.angle + event.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
            self.delegate.activateScrollView(enable: true)
        }
        
        self.backgroundLine.onPinch { (event) in
            guard let _ = event.node else { print("problem on line pinch")
                return
            }
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx, transform!.dy, transform!.scale * event.scale, transform!.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
            
            let newStroke = Stroke(fill: self.delegate.stroke.fill, width: self.delegate.stroke.width/(transform!.scale * event.scale))
            let newCircleStroke = Stroke(fill: Color.clear, width: self.delegate.stroke.width/(transform!.scale * event.scale))
            self.updateStroke(stroke: newStroke)
            self.updateCircleStroke(stroke: newCircleStroke)
            self.updateSize(scale: transform!.scale * event.scale)
            self.delegate.activateScrollView(enable: true)
        }
        self.onTap(f: { (event) in
            if self.delegate.activeTool == .none { return }
            guard let node = event.node else { print("problem on panel pan")
                return
            }
            if self.delegate.activeTool == .delete {
                self.delegate.shapesGroup.contents.removeAll(where: { (shape) -> Bool in
                    shape.hash == node.hash
                })
            }
        })
    }
}
