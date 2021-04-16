//
//  CustomText.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 10/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class CustomText: Group, CustomShape {
    
    var annotationId: Int!
    var id: Int!
    var type: Annotation.Types!
    var comment: String = ""
    weak var delegate: MacawViewDelegate?
    var stroke: Stroke!
    
    var textNode: Text!
    
    var rectLimit: Shape!
    
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
    
    var activeContents: [Node]!
    var inactiveContents: [Node]!
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                self.delegate?.customTexts.removeAll(where: { (text) -> Bool in
                    text == self
                })
                self.delegate?.customTexts.append(self)
                self.delegate?.macawTextActive = true
            } else {
                self.delegate?.macawTextActive = false
            }
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
    
    init(text: String, startPoint: Point, lastPoint: Point, stroke: Stroke, type: Annotation.Types, id: Int? = nil, annotationId: Int, comment: String) {
        super.init()
        self.type = type
        self.id = id
        self.annotationId = annotationId
        self.comment = comment
        self.stroke = stroke
       
        updatePoints(startPoint: startPoint, lastPoint: lastPoint)
        
        let font: Font = Font(size: Int(stroke.width*3))
        
        textNode = Text(text: text, font: font, fill: stroke.fill, place: .move(startPoint.x, startPoint.y))
        rectLimit = Shape(form: Rect(), fill: Color.clear, stroke: Stroke(fill: Color.white, width: 2, dashes: [5, 5]))
        
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
        
        activeContents = [idText, textNode, rectLimit, anchor0, anchor1, anchor2, anchor3, anchor01, anchor02, anchor13, anchor23, circle0, circle1, circle2, circle3, circle01, circle02, circle23, circle13]
        inactiveContents = [textNode]
        contents = activeContents
        
        updateFormFromPoints()
    }
    
    func setText(text: String) {
        textNode.text = text
    }
    
    func updateTextBounds() { //logic for automatic line breaking in text
        let text = textNode.text
        var textString = ""
        for i in 0..<text.count {
            let char = text[i]
            if char == "\n" {
                continue
            }
            textString.append(char)
            self.setText(text: textString)
            if self.textNode.bounds.h > self.rectLimit.form.bounds().h {
                updateBoundsHeight()
            }
            if self.textNode.bounds.w > self.rectLimit.form.bounds().w {
                let textStringWithoutBreak = textString
                textString = breakLine(text: textString)
                self.setText(text: textString)
                if self.textNode.bounds.w > self.rectLimit.form.bounds().w {
                    updateBoundsWidth()
                    textString = textStringWithoutBreak
                    self.setText(text: textString)
                }
                if self.textNode.bounds.h > self.rectLimit.form.bounds().h {
                    updateBoundsHeight()
                }
            }
        }
    }
    
    func updateBoundsWidth() {
        let value = self.textNode.bounds.w-self.rectLimit.form.bounds().w
        p1 = Point(x: p1.x+value, y: p1.y)
        p3 = Point(x: p3.x+value, y: p3.y)
        updateFormFromPoints()
    }
    
    func updateBoundsHeight() {
        let value = self.textNode.bounds.h-self.rectLimit.form.bounds().h
        p2 = Point(x: p2.x, y: p2.y+value)
        p3 = Point(x: p3.x, y: p3.y+value)
        updateFormFromPoints()
    }
    
    func breakLine(text: String) -> String {
        var text = text
        for i in stride(from: text.count-1, to: 0, by: -1) {
            if text[i] == " " {
                let offset = i == text.count-1 ? i : i+1
                text.insert("\n", at: text.index(text.startIndex, offsetBy: offset))
                break
            }
        }
        return text
    }

    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
        self.stroke = stroke
        idText.fill = self.stroke.fill
        textNode.fill = stroke.fill
        textNode.font = Font(size: Int(stroke.width*3))
        updateTextBounds()
    }
    
    func getCenter() -> Point? {
        return rectLimit.bounds?.center()
    }
    
    func activateCircleAction() {
        
    }
    
    func deleteShape() {
        contents = []
    }
    
//    func redoShape() {
//        contents = [textNode]
//    }
    
    func setTransformEvents() {
        
        circle0.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP0 = Point(x: loc.x, y: loc.y)
            self?.p0 = newP0
            self?.p1 = Point(x: self!.p1.x, y: self!.p0.y)
            self?.p2 = Point(x: self!.p0.x, y: self!.p2.y)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle1.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP1 = Point(x: loc.x, y: loc.y)
            self?.p1 = newP1
            self?.p0 = Point(x: self!.p0.x, y: self!.p1.y)
            self?.p3 = Point(x: self!.p1.x, y: self!.p3.y)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle2.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP2 = Point(x: loc.x, y: loc.y)
            self?.p2 = newP2
            self?.p0 = Point(x: self!.p2.x, y: self!.p0.y)
            self?.p3 = Point(x: self!.p3.x, y: self!.p2.y)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle3.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP3 = Point(x: loc.x, y: loc.y)
            self?.p3 = newP3
            self?.p1 = Point(x: self!.p3.x, y: self!.p1.y)
            self?.p2 = Point(x: self!.p2.x, y: self!.p3.y)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle01.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP01 = Point(x: loc.x, y: loc.y)
            self?.p0 = Point(x: self!.p0.x, y: newP01.y)
            self?.p1 = Point(x: self!.p1.x, y: newP01.y)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle02.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP02 = Point(x: loc.x, y: loc.y)
            self?.p0 = Point(x: newP02.x, y: self!.p0.y)
            self?.p2 = Point(x: newP02.x, y: self!.p2.y)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle13.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP13 = Point(x: loc.x, y: loc.y)
            self?.p1 = Point(x: newP13.x, y: self!.p1.y)
            self?.p3 = Point(x: newP13.x, y: self!.p3.y)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle23.onTouchMoved { [weak self] (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self?.delegate?.activateScrollView(enable: false)
            
            let newP23 = Point(x: loc.x, y: loc.y)
            self?.p2 = Point(x: self!.p2.x, y: newP23.y)
            self?.p3 = Point(x: self!.p3.x, y: newP23.y)
            self?.delegate?.activateScrollView(enable: true)
            self?.updateFormFromPoints()
        }
        circle0.onTouchReleased { [weak self] (event) in
            self?.updateTextBounds()
        }
        circle1.onTouchReleased { [weak self] (event) in
            self?.updateTextBounds()
        }
        circle2.onTouchReleased { [weak self] (event) in
            self?.updateTextBounds()
        }
        circle3.onTouchReleased { [weak self] (event) in
            self?.updateTextBounds()
        }
        circle01.onTouchReleased { [weak self] (event) in
            self?.updateTextBounds()
        }
        circle02.onTouchReleased { [weak self] (event) in
            self?.updateTextBounds()
        }
        circle13.onTouchReleased { [weak self] (event) in
            self?.updateTextBounds()
        }
        circle23.onTouchReleased { [weak self] (event) in
            self?.updateTextBounds()
        }
        
        self.onTap(f: { [weak self] (event) in

            if let previousText = self?.delegate?.lastActiveShape as? CustomText {
                previousText.isActive = false
                self?.delegate?.lastActiveShape = nil
                return
            }
            
            self?.isActive = !self!.isActive
            self?.delegate?.setLastActiveShape(newShape: self!)
        })
        
        rectLimit.onPan { [weak self] event in
            guard let _ = event.node else { print("problem on arc pan")
                return
            }
            if !self!.isActive { return }
            self?.delegate?.activateScrollView(enable: false)
            self?.move(dx: event.dx, dy: event.dy)
            self?.delegate?.activateScrollView(enable: true)
        }
//        self.delegate?.shapesGroup.contents.append(self)
    }
    
    func move(dx: Double, dy: Double) {
        p0 = Point(x: p0.x + dx, y: p0.y + dy)
        p1 = Point(x: p1.x + dx, y: p1.y + dy)
        p2 = Point(x: p2.x + dx, y: p2.y + dy)
        p3 = Point(x: p3.x + dx, y: p3.y + dy)
        updateFormFromPoints()
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        updatePoints(startPoint: startPoint, lastPoint: lastPoint)
        updateFormFromPoints()
    }
    
    func updatePoints(startPoint: Point, lastPoint: Point) {
        p0 = startPoint
        p3 = lastPoint
        p1 = Point(x: p3.x, y: p0.y)
        p2 = Point(x: p0.x, y: p3.y)
    }
    
    func updateFormFromPoints(updateText: Bool = false) {
        let width = p3.x - p0.x
        let height = p3.y - p0.y
        rectLimit.form = Rect(x: p0.x, y: p0.y, w: width, h: height)
        textNode.place = .move(dx: p0.x, dy: p0.y)
        
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

}
