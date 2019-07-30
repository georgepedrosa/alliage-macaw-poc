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
    
    var drawing: Shape!
    var backgroundDrawing: Shape!
    //var path: PathBuilder!
    
    var tempLine: Shape!
    
    var circle0: Shape!
    var circle1: Shape!
    var circle2: Shape!
    
    var line1: Shape!
    var line2: Shape!
    
    var p0: Point!
    var p1: Point!
    var p2: Point!
    
    var delegate: MacawViewDelegate!
    
    var stroke: Stroke!
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                contents = [line1, line2, drawing, backgroundDrawing, circle0, circle1, circle2]
            } else {
                contents = [drawing, backgroundDrawing]
            }
        }
    }

    init(p0: Point, p1: Point, p2: Point, delegate: MacawViewDelegate, stroke: Stroke) {
        super.init()
        
        self.delegate = delegate
        self.stroke = stroke
        
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        
        let locusCircle0 = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle0 = Shape(form: locusCircle0, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        let locusCircle1 = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle1 = Shape(form: locusCircle1, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        let locusCircle2 = Circle(cx: p2.x, cy: p2.y, r: 15)
        circle2 = Shape(form: locusCircle2, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        
        let locusLine1 = Line(x1: p0.x, y1: p0.y, x2: p1.x, y2: p1.y)
        line1 = Shape(form: locusLine1, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: 2.0))
        let locusLine2 = Line(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y)
        line2 = Shape(form: locusLine2, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: 2.0))
        
        var path: PathBuilder = MoveTo(x: p0.x, y: p0.y)
        
        for index in 1...100 {
            let t: Double = Double(index)/100
            let x = pow((1.0-t), 2.0)*p0.x + 2*(1.0-t)*t*p1.x + pow(t, 2.0)*p2.x
            let y = pow((1.0-t), 2.0)*p0.y + 2*(1.0-t)*t*p1.y + pow(t, 2.0)*p2.y
            
            path = path.lineTo(x: x, y: y)
        }
        
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
        
        contents = [line1, line2, drawing, backgroundDrawing, circle0, circle1, circle2]
    }
    
    
    func setArcEvents() {
        
        var p0 = Point()
        var p1 = Point(x: 0, y: 0)
        var p2 = Point(x: 0, y: 0)
        var tempArc: CustomArc!
        
        self.circle0.onTouchPressed { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let center = self.getCenter()
            p1 = Point(x: self.p1.x - self.p0.x, y: self.p1.y - self.p0.y)
            let p1Aux = Shape(form: Point(x: 0, y: 0))
            p1Aux.place = Transform.move(dx: transform!.dx + center!.x, dy:  transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y).move(dx: p1.x, dy: p1.y)
            p1 = Point(x: p1Aux.place.dx, y: p1Aux.place.dy)
            p2 = Point(x: self.p2.x - self.p0.x, y: self.p2.y - self.p0.y)
            let p2Aux = Shape(form: Point(x: 0, y: 0))
            p2Aux.place = Transform.move(dx: transform!.dx + center!.x, dy:  transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y).move(dx: p2.x, dy: p2.y)
            p2 = Point(x: p2Aux.place.dx, y: p2Aux.place.dy)
            tempArc = CustomArc(p0: loc, p1: p1, p2: p2, delegate: self.delegate, stroke: self.stroke)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == self.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = tempArc
        }
        
        self.circle1.onTouchPressed { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let center = self.getCenter()
            let p0Aux = Shape(form: Point(x: 0, y: 0))
            p0Aux.place = Transform.move(dx: transform!.dx + center!.x, dy: transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y)
            p0 = Point(x: p0Aux.place.dx, y: p0Aux.place.dy)
            p2 = Point(x: self.p2.x - self.p0.x, y: self.p2.y - self.p0.y)
            let p2Aux = Shape(form: Point(x: 0, y: 0))
            p2Aux.place = Transform.move(dx: transform!.dx + center!.x, dy:  transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y).move(dx: p2.x, dy: p2.y)
            p2 = Point(x: p2Aux.place.dx, y: p2Aux.place.dy)
            tempArc = CustomArc(p0: p0, p1: loc, p2: p2, delegate: self.delegate, stroke: self.stroke)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == self.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = tempArc
        }
        
        self.circle2.onTouchPressed { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let center = self.getCenter()
            let p0Aux = Shape(form: Point(x: 0, y: 0))
            p0Aux.place = Transform.move(dx: transform!.dx + center!.x, dy: transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y)
            p0 = Point(x: p0Aux.place.dx, y: p0Aux.place.dy)
            p1 = Point(x: self.p1.x - self.p0.x, y: self.p1.y - self.p0.y)
            let p1Aux = Shape(form: Point(x: 0, y: 0))
            p1Aux.place = Transform.move(dx: transform!.dx + center!.x, dy:  transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y).move(dx: p1.x, dy: p1.y)
            p1 = Point(x: p1Aux.place.dx, y: p1Aux.place.dy)
            tempArc = CustomArc(p0: p0, p1: p1, p2: loc, delegate: self.delegate, stroke: self.stroke)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == self.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = tempArc
        }
        self.circle0.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            tempArc.updateForm(p0: loc, p1: tempArc.p1, p2: tempArc.p2)
            //arc.moveCircle(circle: .zero, toPoint: loc)
        }
        self.circle1.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            tempArc.updateForm(p0: tempArc.p0, p1: loc, p2: tempArc.p2)
            //arc.moveCircle(circle: .one, toPoint: loc)
        }
        self.circle2.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            tempArc.updateForm(p0: tempArc.p0, p1: tempArc.p1, p2: loc)
            //arc.moveCircle(circle: .two, toPoint: loc)
        }
        self.circle0.onTouchReleased { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.delegate.activateScrollView(enable: true)
            
            let x1 = tempArc.p1.x - loc.x
            let y1 = tempArc.p1.y - loc.y
            let x2 = tempArc.p2.x - loc.x
            let y2 = tempArc.p2.y - loc.y
            
            let newArc = CustomArc(p0: Point(0, 0), p1: Point(x: x1, y: y1), p2: Point(x: x2, y: y2), delegate: self.delegate, stroke: self.stroke)
            newArc.place = Transform.move(dx: loc.x, dy: loc.y).scale(sx: 1, sy: 1)
            newArc.p0 = loc
            newArc.p1 = tempArc.p1
            newArc.p2 = tempArc.p2
            self.delegate.shapeTransformations[newArc.hash] = (loc.x, loc.y, 1, 0)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == tempArc.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = newArc
            newArc.setArcEvents()
        }
        self.circle1.onTouchReleased { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.delegate.activateScrollView(enable: true)
            
            let x1 = loc.x - p0.x
            let y1 = loc.y - p0.y
            let x2 = p2.x - p0.x
            let y2 = p2.y - p0.y
            
            let newArc = CustomArc(p0: Point(0, 0), p1: Point(x: x1, y: y1), p2: Point(x: x2, y: y2), delegate: self.delegate, stroke: self.stroke)
            newArc.place = Transform.move(dx: p0.x, dy: p0.y).scale(sx: 1, sy: 1)
            newArc.p0 = p0
            newArc.p1 = loc
            newArc.p2 = p2
            self.delegate.shapeTransformations[newArc.hash] = (p0.x,p0.y, 1, 0)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == tempArc.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = newArc
            newArc.setArcEvents()
        }
        self.circle2.onTouchReleased { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.delegate.activateScrollView(enable: true)
            
            let x1 = p1.x - p0.x
            let y1 = p1.y - p0.y
            let x2 = loc.x - p0.x
            let y2 = loc.y - p0.y
            
            let newArc = CustomArc(p0: Point(0, 0), p1: Point(x: x1, y: y1), p2: Point(x: x2, y: y2), delegate: self.delegate, stroke: self.stroke)
            newArc.place = Transform.move(dx: p0.x, dy: p0.y).scale(sx: 1, sy: 1)
            newArc.p0 = p0
            newArc.p1 = p1
            newArc.p2 = loc
            self.delegate.shapeTransformations[newArc.hash] = (p0.x,p0.y, 1, 0)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == tempArc.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = newArc
            newArc.setArcEvents()
        }
        self.onTap { (event) in
            guard let _ = event.node else { print("problem on arc tap")
                return
            }
            
            if self.delegate.activeTool == .delete {
                self.delegate.shapesGroup.contents.removeAll(where: { (shape) -> Bool in
                    shape.hash == self.hash
                })
            } else {
                self.isActive = !self.isActive
            }
        }
        self.backgroundDrawing.onPan { (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
            self.delegate.activateScrollView(enable: true)
        }
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        
        let p0 = startPoint
        let x = (lastPoint.x + startPoint.x)/2
        let y = (lastPoint.y + startPoint.y)/2
        let p1 = Point(x, y)
        let p2 = lastPoint
        
        var newPath: PathBuilder!
        newPath = MoveTo(x: p0.x, y: p0.y)
        newPath = newPath.lineTo(x: p2.x, y: p2.y)
        
        drawing.form = newPath.build()
        backgroundDrawing.form = newPath.build()
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle2.form = Circle(cx: p2.x, cy: p2.y, r: 15)
        line1.form = Line(x1: p0.x, y1: p0.y, x2: p1.x, y2: p1.y)
        line2.form = Line(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y)
    }
    
    func updateForm(p0: Point, p1: Point, p2: Point) {
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
        line1.form = Line(x1: p0.x, y1: p0.y, x2: p1.x, y2: p1.y)
        line2.form = Line(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y)
    }
    
    func updateStroke(stroke: Stroke) {
        drawing.stroke = stroke
    }
    
    func deleteShape() {
        contents = []
    }
    
    func redoShape() {
        contents = [drawing]
    }
    
    func getCenter() -> Point? {
        return p1
    }
    
    func activateCircleAction() {
        
    }
    
}
