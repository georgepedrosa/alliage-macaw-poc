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
    
    public var active: Bool = false
    public var rect: Shape!
    var textNode: Text!
    
    var isActive: Bool = true {
        didSet {
            rect.stroke = (isActive ? Stroke(fill: Color.blue, width: 2.0) : Stroke(fill: Color.clear, width: 2.0))
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        
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

}
