//
//  CustomEllipse.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 07/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class CustomEllipse: Group, CustomShape {
    
    var delegate: MacawViewDelegate!
    var stroke: Stroke!
    
    var ellipse: Shape!
    var backgroundRect: Shape!
    
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
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                contents = [backgroundRect, ellipse, anchor0, anchor1, anchor2, anchor3, anchor01, anchor02, anchor13, anchor23, circle0, circle1, circle2, circle3, circle01, circle02, circle23, circle13]
            } else {
                contents = [ellipse]
            }
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        self.stroke = stroke
        updatePoints(startPoint: startPoint, lastPoint: lastPoint)
        
        let width = lastPoint.x - startPoint.x
        let height = lastPoint.y - startPoint.y
        let ellipseLocus = Ellipse(cx: startPoint.x + width/2.0, cy: startPoint.y + height/2.0, rx: width/2.0, ry: height/2.0)
        ellipse = Shape(form: ellipseLocus, fill: Color.clear, stroke: stroke)
        backgroundRect = Shape(form: ellipseLocus.bounds(), fill: Color.clear, stroke: Stroke(fill: Color.blue, width: 2))
        
        let locusCircle0 = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle0 = Shape(form: locusCircle0, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        let locusCircle1 = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle1 = Shape(form: locusCircle1, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        let locusCircle2 = Circle(cx: p2.x, cy: p2.y, r: 15)
        circle2 = Shape(form: locusCircle2, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        let locusCircle3 = Circle(cx: p3.x, cy: p3.y, r: 15)
        circle3 = Shape(form: locusCircle3, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        
        let locusCircle01 = Circle(cx: (p0.x + p1.x)/2, cy: p0.y, r: 15)
        circle01 = Shape(form: locusCircle01, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        let locusCircle02 = Circle(cx: p0.x, cy: (p0.y + p2.y)/2, r: 15)
        circle02 = Shape(form: locusCircle02, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        let locusCircle23 = Circle(cx: (p2.x + p3.x)/2, cy: p2.y, r: 15)
        circle23 = Shape(form: locusCircle23, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        let locusCircle13 = Circle(cx: p1.x, cy: (p1.y + p3.y)/2, r: 15)
        circle13 = Shape(form: locusCircle13, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 5.0))
        
        let locusAnchor0 = Circle(cx: p0.x, cy: p0.y, r: 2)
        let locusAnchor1 = Circle(cx: p1.x, cy: p1.y, r: 2)
        let locusAnchor2 = Circle(cx: p2.x, cy: p2.y, r: 2)
        let locusAnchor3 = Circle(cx: p3.x, cy: p3.y, r: 2)
        let locusAnchor01 = Circle(cx: (p0.x + p1.x)/2, cy: p0.y, r: 2)
        let locusAnchor02 = Circle(cx: p0.x, cy: (p0.y + p2.y)/2, r: 2)
        let locusAnchor23 = Circle(cx: (p2.x + p3.x)/2, cy: p2.y, r: 2)
        let locusAnchor13 = Circle(cx: p1.x, cy: (p1.y + p3.y)/2, r: 2)
        
        anchor0 = Shape(form: locusAnchor0, fill: Color.green, stroke: Stroke(fill: Color.green, width: 5.0))
        anchor1 = Shape(form: locusAnchor1, fill: Color.green, stroke: Stroke(fill: Color.green, width: 5.0))
        anchor2 = Shape(form: locusAnchor2, fill: Color.green, stroke: Stroke(fill: Color.green, width: 5.0))
        anchor3 = Shape(form: locusAnchor3, fill: Color.green, stroke: Stroke(fill: Color.green, width: 5.0))
        anchor01 = Shape(form: locusAnchor01, fill: Color.green, stroke: Stroke(fill: Color.green, width: 5.0))
        anchor02 = Shape(form: locusAnchor02, fill: Color.green, stroke: Stroke(fill: Color.green, width: 5.0))
        anchor23 = Shape(form: locusAnchor23, fill: Color.green, stroke: Stroke(fill: Color.green, width: 5.0))
        anchor13 = Shape(form: locusAnchor13, fill: Color.green, stroke: Stroke(fill: Color.green, width: 5.0))
        
        contents = [backgroundRect, ellipse, anchor0, anchor1, anchor2, anchor3, anchor01, anchor02, anchor13, anchor23, circle0, circle1, circle2, circle3, circle01, circle02, circle23, circle13]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        updatePoints(startPoint: startPoint, lastPoint: lastPoint)
        updateFormFromPoints()
        
//        let width = lastPoint.x - startPoint.x
//        let height = lastPoint.y - startPoint.y
//        ellipse.form = Ellipse(cx: startPoint.x + width/2.0, cy: startPoint.y + height/2.0, rx: width/2.0, ry: height/2.0)
//        backgroundRect.form = ellipse.form.bounds()
//        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 15)
//        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 15)
//        circle2.form = Circle(cx: p2.x, cy: p2.y, r: 15)
//        circle3.form = Circle(cx: p3.x, cy: p3.y, r: 15)
//
//        circle01.form = Circle(cx: (p0.x + p1.x)/2, cy: p0.y, r: 15)
//        circle02.form = Circle(cx: p0.x, cy: (p0.y + p2.y)/2, r: 15)
//        circle23.form = Circle(cx: (p2.x + p3.x)/2, cy: p2.y, r: 15)
//        circle13.form = Circle(cx: p1.x, cy: (p1.y + p3.y)/2, r: 15)
    }
    
    func setTransformEvents() {
        circle0.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP0 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            
            self.p0 = newP0
            self.p1 = Point(x: self.p1.x, y: self.p0.y)
            self.p2 = Point(x: self.p0.x, y: self.p2.y)
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        
        circle1.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP1 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            
            self.p1 = newP1
            self.p0 = Point(x: self.p0.x, y: self.p1.y)
            self.p3 = Point(x: self.p1.x, y: self.p3.y)
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        circle2.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP2 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            
            self.p2 = newP2
            self.p0 = Point(x: self.p2.x, y: self.p0.y)
            self.p3 = Point(x: self.p3.x, y: self.p2.y)
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        circle3.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            let newP3 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            
            self.p3 = newP3
            self.p1 = Point(x: self.p3.x, y: self.p1.y)
            self.p2 = Point(x: self.p2.x, y: self.p3.y)
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        circle01.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            
            let newP01 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            
            self.p0 = Point(x: self.p0.x, y: newP01.y)
            self.p1 = Point(x: self.p1.x, y: newP01.y)
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        circle02.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            
            let newP02 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            
            self.p0 = Point(x: newP02.x, y: self.p0.y)
            self.p2 = Point(x: newP02.x, y: self.p2.y)
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        circle13.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            
            let newP13 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            
            self.p1 = Point(x: newP13.x, y: self.p1.y)
            self.p3 = Point(x: newP13.x, y: self.p3.y)
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        circle23.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            
            let newP23 = Point(x: loc.x - transform!.dx, y: loc.y - transform!.dy)
            
            self.p2 = Point(x: self.p2.x, y: newP23.y)
            self.p3 = Point(x: self.p3.x, y: newP23.y)
            self.delegate.activateScrollView(enable: true)
            self.updateFormFromPoints()
        }
        ellipse.onPan { (event) in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            if !self.isActive {
                return
            }
            self.delegate.activateScrollView(enable: false)
            
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
            self.delegate.activateScrollView(enable: true)
        }
    }
    
    func updateFormFromPoints() {
        
        let width = p3.x - p0.x
        let height = p3.y - p0.y
        
        ellipse.form = Ellipse(cx: p0.x + width/2.0, cy: p0.y + height/2.0, rx: width/2.0, ry: height/2.0)
        backgroundRect.form = ellipse.form.bounds()
        
        circle0.form = Circle(cx: p0.x, cy: p0.y, r: 15)
        circle1.form = Circle(cx: p1.x, cy: p1.y, r: 15)
        circle2.form = Circle(cx: p2.x, cy: p2.y, r: 15)
        circle3.form = Circle(cx: p3.x, cy: p3.y, r: 15)
        
        circle01.form = Circle(cx: (p0.x + p1.x)/2, cy: p0.y, r: 15)
        circle02.form = Circle(cx: p0.x, cy: (p0.y + p2.y)/2, r: 15)
        circle23.form = Circle(cx: (p2.x + p3.x)/2, cy: p2.y, r: 15)
        circle13.form = Circle(cx: p1.x, cy: (p1.y + p3.y)/2, r: 15)
        
        anchor0.form = Circle(cx: p0.x, cy: p0.y, r: 2)
        anchor1.form = Circle(cx: p1.x, cy: p1.y, r: 2)
        anchor2.form = Circle(cx: p2.x, cy: p2.y, r: 2)
        anchor3.form = Circle(cx: p3.x, cy: p3.y, r: 2)
        anchor01.form = Circle(cx: (p0.x + p1.x)/2, cy: p0.y, r: 2)
        anchor02.form = Circle(cx: p0.x, cy: (p0.y + p2.y)/2, r: 2)
        anchor23.form = Circle(cx: (p2.x + p3.x)/2, cy: p2.y, r: 2)
        anchor13.form = Circle(cx: p1.x, cy: (p1.y + p3.y)/2, r: 2)
    }
    
    func updateStroke(stroke: Stroke) {
        ellipse.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return self.ellipse.bounds?.center()
    }
    
    func updatePoints(startPoint: Point, lastPoint: Point) {
        p0 = startPoint
        p3 = lastPoint
        p1 = Point(x: p3.x, y: p0.y)
        p2 = Point(x: p0.x, y: p3.y)
    }

}
