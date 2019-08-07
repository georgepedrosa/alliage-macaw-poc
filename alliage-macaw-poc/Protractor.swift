//
//  Protractor.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 17/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class Protractor: Group, CustomShape {
    
    var line1: Shape!
    var line2: Shape!
    var backgroundLine1: Shape!
    var backgroundLine2: Shape!
    var circle0: Shape!
    var circle1: Shape!
    var circle2: Shape!
    var arc: Shape!
    var text: Text!
    
    var p0: Point!
    var p1: Point!
    var p2: Point!
    
    let degreesPerRadian: Double = 57.2958
    let protractorAngle = Double.pi/4

    var isActive: Bool = true {
        didSet {
            if isActive {
                contents = [arc, line1, line2, backgroundLine1, backgroundLine2, circle0, circle1, circle2, text]
                line1.stroke = Stroke(fill: Color.blue, width: self.stroke.width)
                line2.stroke = Stroke(fill: Color.blue, width: self.stroke.width)
            } else {
                contents = [arc, line1, line2, backgroundLine1, backgroundLine2, text]
                line1.stroke = stroke
                line2.stroke = stroke
            }
        }
    }
    
    var delegate: MacawViewDelegate!
    
    var stroke: Stroke!

//    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
//        super.init()
//
//        self.stroke = stroke
//
//        p0 = startPoint
//        p1 = lastPoint
//
//        let d = distance(startPoint, lastPoint)
//
//        let angle = atan2(p1.y - p0.y, p1.x - p0.x)
//
//        let x2 = p0.x + d * cos(angle + protractorAngle)
//        let y2 = p0.y + d * sin(angle + protractorAngle)
//
//        p2 = Point(x: x2, y: y2)
//
//        let locusLine1 = Line(p0.x, p0.y, p1.x, p1.y)
//        let locusLine2 = Line(p0.x, p0.y, x2, y2)
//
//        line1 = Shape(form: locusLine1, fill: Color.clear, stroke: stroke)
//        line2 = Shape(form: locusLine2, fill: Color.clear, stroke: stroke)
//        backgroundLine1 = Shape(form: locusLine1, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
//        backgroundLine2 = Shape(form: locusLine2, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
//
//        let locusCircle0 = Circle(cx: p0.x, cy: p0.y, r: 15)
//        circle0 = Shape(form: locusCircle0, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
//        let locusCircle1 = Circle(cx: p1.x, cy: p1.y, r: 15)
//        circle1 = Shape(form: locusCircle1, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
//        let locusCircle2 = Circle(cx: p2.x, cy: p2.y, r: 15)
//        circle2 = Shape(form: locusCircle2, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
//
//        let ellipseLocus = Ellipse(cx: p0.x, cy: p0.y, rx: 40, ry: 40)
//
//        let theta1 = atan2(p1.y - p0.y, p1.x - p0.x)
//        let theta2 = atan2(p2.y - p0.y, p2.x - p0.x)
//
//        let arcLocus = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
//
//        arc = Shape(form: arcLocus, fill: Color.clear, stroke: Stroke(fill: Color.orange, width: 5.0))
//
//        let angleInDegrees = (Double.pi/4)*degreesPerRadian
//
//        text = Text(text: String(format: "%.2f", angleInDegrees) + "º", fill: Color.blue, place: .move(p0.x, p0.y))
//
//        contents = [arc, line1, line2, backgroundLine1, backgroundLine2, circle0, circle1, circle2, text]
//    }
    
    init(p0: Point, p1: Point, p2: Point, delegate: MacawViewDelegate, stroke: Stroke) {
        super.init()
        self.delegate = delegate
        self.stroke = stroke

        self.p0 = p0
        self.p1 = p1
        
        //let d = distance(p0, p1)
        
        self.p2 = p2
        
        let locusLine1 = Line(p0.x, p0.y, p1.x, p1.y)
        let locusLine2 = Line(p0.x, p0.y, p2.x, p2.y)
        
        line1 = Shape(form: locusLine1, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: self.stroke.width))
        line2 = Shape(form: locusLine2, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: self.stroke.width))
        backgroundLine1 = Shape(form: locusLine1, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        backgroundLine2 = Shape(form: locusLine2, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let locusCircle0 = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle0 = Shape(form: locusCircle0, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        let locusCircle1 = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle1 = Shape(form: locusCircle1, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        let locusCircle2 = Circle(cx: p2.x, cy: p2.y, r: 15)
        circle2 = Shape(form: locusCircle2, fill: Color.clear, stroke: Stroke(fill: Color.green, width: 5.0))
        
        let ellipseLocus = Ellipse(cx: p0.x, cy: p0.y, rx: 40, ry: 40)
        
        let theta1 = atan2(p1.y - p0.y, p1.x - p0.x)
        let theta2 = atan2(p2.y - p0.y, p2.x - p0.x)
        
        var angleInDegrees = (theta2-theta1)*degreesPerRadian
        if angleInDegrees < 0 {
            angleInDegrees += 360
        }

        let arcLocus = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
        
        arc = Shape(form: arcLocus, fill: Color.clear, stroke: Stroke(fill: Color.orange, width: self.stroke.width))
        
        text = Text(text: String(format: "%.2f", angleInDegrees) + "º", fill: Color.blue, place: .move(p0.x, p0.y))
        
        var angleText = theta1 + ((theta2 - theta1)/2)
        
        if theta2 >= -Double.pi && theta2 <= -(Double.pi - angleText) && theta1 <= Double.pi && theta1 >= Double.pi - angleText {
            angleText = Double.pi + angleText
        }
        
        let distanceText = 70.0
        
        let textX = distanceText * cos(angleText) + p0.x
        let textY = distanceText * sin(angleText) + p0.y
        
        text.place = .move(dx: textX, dy: textY)
        
        contents = [arc, line1, line2, backgroundLine1, backgroundLine2, circle0, circle1, circle2, text]
    }

    func updateForm(startPoint: Point, lastPoint: Point) {
        
        let d = distance(startPoint, lastPoint)
        let angle = atan2(lastPoint.y - startPoint.y, lastPoint.x - startPoint.x)
        
        self.p2 = Point(x: startPoint.x + d * cos(angle + protractorAngle), y: startPoint.y + d * sin(angle + protractorAngle))
        self.p0 = startPoint
        self.p1 = lastPoint
        
        line1.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        backgroundLine1.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)

        line2.form = Line(startPoint.x, startPoint.y, p2.x, p2.y)
        backgroundLine2.form = Line(startPoint.x, startPoint.y, p2.x, p2.y)
        
        circle0.form = Circle(cx: startPoint.x, cy: startPoint.y, r: 15)
        circle1.form = Circle(cx: lastPoint.x, cy: lastPoint.y, r: 15)
        circle2.form = Circle(cx: p2.x, cy: p2.y, r: 15)
        
        let ellipseLocus = Ellipse(cx: p0.x, cy: p0.y, rx: 40, ry: 40)
        
        let theta1 = atan2(p1.y - p0.y, p1.x - p0.x)
        let theta2 = atan2(p2.y - p0.y, p2.x - p0.x)

        arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
        
        var angleText = theta1 + ((theta2 - theta1)/2)
        
        if theta2 >= -Double.pi && theta2 <= -(Double.pi - protractorAngle) && theta1 <= Double.pi && theta1 >= Double.pi - protractorAngle {
            angleText = Double.pi + angleText
        }
        
        let distanceText = 70.0
        
        let textX = distanceText * cos(angleText) + p0.x
        let textY = distanceText * sin(angleText) + p0.y
        
        text.text = "45º"
        
        text.place = .move(dx: textX, dy: textY)
        
    }
    
    func updateForm(p0: Point, p1: Point, p2: Point) {
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle2.form = Circle(cx: p2.x, cy: p2.y, r: 15)
        line1.form = Line(p0.x, p0.y, p1.x, p1.y)
        backgroundLine1.form = Line(p0.x, p0.y, p1.x, p1.y)
        line2.form = Line(p0.x, p0.y, p2.x, p2.y)
        backgroundLine2.form = Line(p0.x, p0.y, p1.x, p1.y)
        
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        
        let ellipseLocus = Ellipse(cx: p0.x, cy: p0.y, rx: 40, ry: 40)
        
        let theta1 = atan2(p1.y - p0.y, p1.x - p0.x)
        let theta2 = atan2(p2.y - p0.y, p2.x - p0.x)
        
        var angleInDegrees = (theta2-theta1)*degreesPerRadian
        if angleInDegrees < 0 {
            angleInDegrees += 360
        }
        
        arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
        
        text.text = String(format: "%.2f", angleInDegrees) + "º"
        
        var angleText = theta1 + ((theta2 - theta1)/2)
        
        if theta2 >= -Double.pi && theta2 <= -(Double.pi - angleText) && theta1 <= Double.pi && theta1 >= Double.pi - angleText {
            angleText = Double.pi + angleText
        }
        
        let distanceText = 70.0
        
        let textX = distanceText * cos(angleText) + p0.x
        let textY = distanceText * sin(angleText) + p0.y
        
        text.place = .move(dx: textX, dy: textY)
    }
    
    func setTransformEvents() {
        
        var p0 = Point()
        var p1 = Point(x: 0, y: 0)
        var p2 = Point(x: 0, y: 0)
        var tempProtractor: Protractor!
        
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
            tempProtractor = Protractor(p0: loc, p1: p1, p2: p2, delegate: self.delegate, stroke: self.stroke)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == self.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = tempProtractor
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
            tempProtractor = Protractor(p0: p0, p1: loc, p2: p2, delegate: self.delegate, stroke: self.stroke)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == self.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = tempProtractor
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
            tempProtractor = Protractor(p0: p0, p1: p1, p2: loc, delegate: self.delegate, stroke: self.stroke)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == self.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = tempProtractor
        }
        self.circle0.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else {
                return
            }
            tempProtractor.updateForm(p0: loc, p1: tempProtractor.p1, p2: tempProtractor.p2)
            //arc.moveCircle(circle: .zero, toPoint: loc)
        }
        self.circle1.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else {
                return
            }
            tempProtractor.updateForm(p0: tempProtractor.p0, p1: loc, p2: tempProtractor.p2)
            //arc.moveCircle(circle: .one, toPoint: loc)
        }
        self.circle2.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else {
                return
            }
            tempProtractor.updateForm(p0: tempProtractor.p0, p1: tempProtractor.p1, p2: loc)
            //arc.moveCircle(circle: .two, toPoint: loc)
        }
        self.circle0.onTouchReleased { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.delegate.activateScrollView(enable: true)
            
            let x1 = tempProtractor.p1.x - loc.x
            let y1 = tempProtractor.p1.y - loc.y
            let x2 = tempProtractor.p2.x - loc.x
            let y2 = tempProtractor.p2.y - loc.y
            
            let newProtractor = Protractor(p0: Point(0, 0), p1: Point(x: x1, y: y1), p2: Point(x: x2, y: y2), delegate: self.delegate, stroke: self.stroke)
            newProtractor.place = Transform.move(dx: loc.x, dy: loc.y).scale(sx: 1, sy: 1)
            newProtractor.p0 = loc
            newProtractor.p1 = tempProtractor.p1
            newProtractor.p2 = tempProtractor.p2
            self.delegate.shapeTransformations[newProtractor.hash] = (loc.x, loc.y, 1, 0)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == tempProtractor.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = newProtractor
            newProtractor.setTransformEvents()
        }
        self.circle1.onTouchReleased { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.delegate.activateScrollView(enable: true)
            
            let x1 = loc.x - p0.x
            let y1 = loc.y - p0.y
            let x2 = p2.x - p0.x
            let y2 = p2.y - p0.y
            
            let newProtractor = Protractor(p0: Point(0, 0), p1: Point(x: x1, y: y1), p2: Point(x: x2, y: y2), delegate: self.delegate, stroke: self.stroke)
            newProtractor.place = Transform.move(dx: p0.x, dy: p0.y).scale(sx: 1, sy: 1)
            newProtractor.p0 = p0
            newProtractor.p1 = loc
            newProtractor.p2 = p2
            self.delegate.shapeTransformations[newProtractor.hash] = (p0.x,p0.y, 1, 0)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == tempProtractor.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = newProtractor
            newProtractor.setTransformEvents()
        }
        self.circle2.onTouchReleased { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.delegate.activateScrollView(enable: true)
            
            let x1 = p1.x - p0.x
            let y1 = p1.y - p0.y
            let x2 = loc.x - p0.x
            let y2 = loc.y - p0.y
            
            let newProtractor = Protractor(p0: Point(0, 0), p1: Point(x: x1, y: y1), p2: Point(x: x2, y: y2), delegate: self.delegate, stroke: self.stroke)
            newProtractor.place = Transform.move(dx: p0.x, dy: p0.y).scale(sx: 1, sy: 1)
            newProtractor.p0 = p0
            newProtractor.p1 = p1
            newProtractor.p2 = loc
            self.delegate.shapeTransformations[newProtractor.hash] = (p0.x,p0.y, 1, 0)
            
            let index = self.delegate.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == tempProtractor.hash
            })
            
            self.delegate.shapesGroup.contents[index!] = newProtractor
            newProtractor.setTransformEvents()
        }
        self.backgroundLine1.onPan { (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            
            if !self.isActive { return }
            
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
            self.delegate.activateScrollView(enable: true)
        }
        self.backgroundLine2.onPan { (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            
            if !self.isActive { return }
            
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
            self.delegate.activateScrollView(enable: true)
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
    }
    
    func moveCircle(circle: ProtractorCircle, toPoint loc: Point) {
        
        switch circle {
        case .zero:
            circle0.form = Circle(cx: loc.x, cy: loc.y, r: 15)
            line1.form = Line(loc.x, loc.y, p1.x, p1.y)
            backgroundLine1.form = Line(loc.x, loc.y, p1.x, p1.y)
            line2.form = Line(loc.x, loc.y, p2.x, p2.y)
            backgroundLine2.form = Line(loc.x, loc.y, p1.x, p1.y)
            
            p0 = loc
            
            let ellipseLocus = Ellipse(cx: p0.x, cy: p0.y, rx: 40, ry: 40)
            
            let theta1 = atan2(p1.y - p0.y, p1.x - p0.x)
            let theta2 = atan2(p2.y - p0.y, p2.x - p0.x)
            
            var angleInDegrees = (theta2-theta1)*degreesPerRadian
            if angleInDegrees < 0 {
                angleInDegrees += 360
            }
            
            arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
            
            text.text = String(format: "%.2f", angleInDegrees) + "º"
            
            var angleText = theta1 + ((theta2 - theta1)/2)
            
            if theta2 >= -Double.pi && theta2 <= -(Double.pi - angleText) && theta1 <= Double.pi && theta1 >= Double.pi - angleText {
                angleText = Double.pi + angleText
            }
            
            let distanceText = 70.0
            
            let textX = distanceText * cos(angleText) + p0.x
            let textY = distanceText * sin(angleText) + p0.y
            
            text.place = .move(dx: textX, dy: textY)

        case .one:
            line1.form = Line(p0.x, p0.y, loc.x, loc.y)
            backgroundLine1.form = Line(p0.x, p0.y, loc.x, loc.y)
            circle1.form = Circle(cx: loc.x, cy: loc.y, r: 15)
            p1 = loc
            
            let ellipseLocus = Ellipse(cx: p0.x, cy: p0.y, rx: 40, ry: 40)
            
            let theta1 = atan2(p1.y - p0.y, p1.x - p0.x)
            let theta2 = atan2(p2.y - p0.y, p2.x - p0.x)
            
            var angleInDegrees = (theta2-theta1)*degreesPerRadian
            if angleInDegrees < 0 {
                angleInDegrees += 360
            }
            
            arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
            text.text = String(format: "%.2f", angleInDegrees) + "º"
            
            var angleText = theta1 + ((theta2 - theta1)/2)
            
            if theta2 >= -Double.pi && theta2 <= -(Double.pi - angleText) && theta1 <= Double.pi && theta1 >= Double.pi - angleText {
                angleText = Double.pi + angleText
            }
            
            let distanceText = 70.0
            
            let textX = distanceText * cos(angleText) + p0.x
            let textY = distanceText * sin(angleText) + p0.y
            
            text.place = .move(dx: textX, dy: textY)
            
        case .two:
            line2.form = Line(p0.x, p0.y, loc.x, loc.y)
            backgroundLine2.form = Line(p0.x, p0.y, loc.x, loc.y)
            circle2.form = Circle(cx: loc.x, cy: loc.y, r: 15)
            p2 = loc
            
            let ellipseLocus = Ellipse(cx: p0.x, cy: p0.y, rx: 40, ry: 40)
            
            let theta1 = atan2(p1.y - p0.y, p1.x - p0.x)
            let theta2 = atan2(p2.y - p0.y, p2.x - p0.x)
            
            var angleInDegrees = (theta2-theta1)*degreesPerRadian
            if angleInDegrees < 0 {
                angleInDegrees += 360
            }
            
            arc.form = Arc(ellipse: ellipseLocus, shift: theta1, extent: theta2 - theta1)
            text.text = String(format: "%.2f", angleInDegrees) + "º"
            
            var angleText = theta1 + ((theta2 - theta1)/2)
            
            if theta2 >= -Double.pi && theta2 <= -(Double.pi - angleText) && theta1 <= Double.pi && theta1 >= Double.pi - angleText {
                angleText = Double.pi + angleText
            }
            
            let distanceText = 70.0
            
            let textX = distanceText * cos(angleText) + p0.x
            let textY = distanceText * sin(angleText) + p0.y
            
            text.place = .move(dx: textX, dy: textY)
        }
        
    }

    func updateStroke(stroke: Stroke) {
        self.stroke = stroke
        line1.stroke = stroke
        line2.stroke = stroke
    }

    func getCenter() -> Point? {
        return line1.bounds?.center()
    }

    func activateCircleAction() {
        
    }
    
    func distance(_ a: Point, _ b: Point) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func getAngle(vertex: Point, pointA: Point, pointB: Point) -> Double {
        //arccos((P122 + P132 - P232) / (2 * P12 * P13))
        
        return acos((pow(distance(vertex, pointA), 2.0) + pow(distance(vertex, pointB), 2.0) - pow(distance(pointA, pointB), 2.0)) / (2 * distance(vertex, pointA) * distance(vertex, pointB)))
    }
}

enum ProtractorCircle {
    case zero
    case one
    case two
}
