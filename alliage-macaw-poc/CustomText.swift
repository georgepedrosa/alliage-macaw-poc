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
    
    public var active: Bool = false
    public var rect: Shape!
    var textNode: Text!
    
    var isActive: Bool = true {
        didSet {
            rect.stroke = (isActive ? Stroke(fill: Color.blue, width: 2.0) : Stroke(fill: Color.clear, width: 2.0))
        }
    }
    
    init(text: String, startPoint: Point, color: Color) {
        super.init()
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
    
    func setTextEvents(startPoint: Point) {
        
        self.onTap(f: { (event) in
            
            if self.delegate.activeTool == .delete {
                self.delegate.shapesGroup.contents.removeAll(where: { (shape) -> Bool in
                    shape.hash == self.hash
                })
                return
            }
            
            if self.delegate.isKeyboardShowing && !self.isActive {
                self.delegate.inputTextView.resignFirstResponder()
                return
            }
            self.isActive = !self.isActive
            if self.isActive {
                self.delegate.customTexts.removeAll(where: { (text) -> Bool in
                    text == self
                })
                for text in self.delegate.customTexts {
                    text.isActive = false //deselects all texts except current one
                }
                self.delegate.customTexts.append(self)
                self.delegate.inputTextView.becomeFirstResponder()
                
            } else {
                self.delegate.inputTextView.resignFirstResponder()
            }
        })
        
        self.onPan { event in
            //self.scrollview.isScrollEnabled = false
            self.delegate.activateScrollView(enable: false)
            let transform = self.delegate.shapeTransformations[self.hash]
            self.delegate.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: self.hash)
            self.delegate.updatePlace(node: self)
            self.delegate.activateScrollView(enable: true)
        }
        self.delegate.shapesGroup.contents.append(self)
    }

}
