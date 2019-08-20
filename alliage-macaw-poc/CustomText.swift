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
    var delegate: MacawViewDelegate!
    var stroke: Stroke!
    
    public var active: Bool = false
    public var rect: Shape!
    var textNode: Text!
    
    var startPoint: Point!
    var p0: Point!
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                rect.stroke = Stroke(fill: Color.blue, width: 2.0)
                self.delegate.customTexts.removeAll(where: { (text) -> Bool in
                    text == self
                })
                self.delegate.customTexts.append(self)
                self.delegate.inputTextView.becomeFirstResponder()
            } else {
                rect.stroke = Stroke(fill: Color.clear, width: 2.0)
                self.delegate.inputTextView.resignFirstResponder()
            }
        }
    }
    
    init(text: String, startPoint: Point, color: Color) {
        super.init()
        
        self.startPoint = startPoint
        p0 = startPoint
        
        textNode = Text(text: text, fill: color, place: .move(startPoint.x, startPoint.y))
        let rectLocus = Rect(x: 0, y: 0, w: 30, h: textNode.bounds.h)
        rect = Shape(form: rectLocus, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: 2.0), place: .move(startPoint.x, startPoint.y))
        
        contents = [rect, textNode]
    }
    
    func setText(text: String) {
        textNode.text = text
        
        let rectLocus: Locus!
        
        if text == "" {
            rectLocus = Rect(x: 0, y: 0, w: 30, h: textNode.bounds.h)
        } else {
            rectLocus = Rect(x: 0, y: 0, w: textNode.bounds.w, h: textNode.bounds.h)
        }
        rect.form = rectLocus
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        
    }
    
    func updateStroke(stroke: Stroke) {
        rect.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return rect.bounds?.center()
    }
    
    func activateCircleAction() {
        
    }
    
    func deleteShape() {
        contents = []
    }
    
    func redoShape() {
        contents = [rect, textNode]
    }
    
    func setTransformEvents(startPoint: Point) {
        
        self.onTap(f: { (event) in
            
            if self.delegate.activeTool == .delete {
                self.delegate.shapesGroup.contents.removeAll(where: { (shape) -> Bool in
                    shape.hash == self.hash
                })
                return
            }

            if let previousText = self.delegate.lastActiveShape as? CustomText {
                previousText.isActive = false
                self.delegate.lastActiveShape = nil
                return
            }
            
            self.isActive = !self.isActive
            self.delegate.setNewShape(shape: self)
        })
        
        self.onPan { event in
            if !self.isActive {
                return
            }
            self.delegate.activateScrollView(enable: false)
            self.move(dx: event.dx, dy: event.dy)
            self.delegate.activateScrollView(enable: true)
        }
        self.delegate.shapesGroup.contents.append(self)
    }
    
    func setTransformEvents() {
        
    }
    
    func move(dx: Double, dy: Double) {
        self.place = .move(self.place.dx + dx, self.place.dy + dy)
        p0 = Point(x: startPoint.x + self.place.dx, y: startPoint.y + self.place.dy)
    }

}
