//
//  Asterisk.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 05/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class Asterisk: Group, CustomShape {
    var delegate: MacawViewDelegate!
    var stroke: Stroke!
    
    var line1: Shape!
    var line2: Shape!
    var line3: Shape!
    var line4: Shape!
    
    var backgroundLine1: Shape!
    var backgroundLine2: Shape!
    var backgroundLine3: Shape!
    var backgroundLine4: Shape!
    
    var backgroundRect: Shape!
    
    var isActive: Bool = true {
        didSet {
            if isActive {
                contents = [line1, backgroundLine1, line2, backgroundLine2, line3, backgroundLine3, line4, backgroundLine4, backgroundRect]
            } else {
                contents = [line1, backgroundLine1, line2, backgroundLine2, line3, backgroundLine3, line4, backgroundLine4]
            }
        }
    }
    
    required init(startPoint: Point, lastPoint: Point, stroke: Stroke) {
        super.init()
        
        self.stroke = stroke

        let x1 = startPoint.x
        let y1 = startPoint.y
        
        let x2 = startPoint.x + 30
        let y2 = startPoint.y + 30
        
        let cx = (x1+x2)/2
        let cy = (y1+y2)/2
        
        let x3 = (  (x1 - cx) * cos(0.78) + (y1 - cy) * sin(0.78) ) + cx
        let y3 = ( -(x1 - cx) * sin(0.78) + (y1 - cy) * cos(0.78) ) + cy
        
        let x4 = (  (x2 - cx) * cos(0.78) + (y2 - cy) * sin(0.78) ) + cx
        let y4 = ( -(x2 - cx) * sin(0.78) + (y2 - cy) * cos(0.78) ) + cy
        
        let x5 = (  (x1 - cx) * cos(1.57) + (y1 - cy) * sin(1.57) ) + cx
        let y5 = ( -(x1 - cx) * sin(1.57) + (y1 - cy) * cos(1.57) ) + cy
        
        let x6 = (  (x2 - cx) * cos(1.57) + (y2 - cy) * sin(1.57) ) + cx
        let y6 = ( -(x2 - cx) * sin(1.57) + (y2 - cy) * cos(1.57) ) + cy
        
        let x7 = (  (x1 - cx) * cos(2.36) + (y1 - cy) * sin(2.36) ) + cx
        let y7 = ( -(x1 - cx) * sin(2.36) + (y1 - cy) * cos(2.36) ) + cy
        
        let x8 = (  (x2 - cx) * cos(2.36) + (y2 - cy) * sin(2.36) ) + cx
        let y8 = ( -(x2 - cx) * sin(2.36) + (y2 - cy) * cos(2.36) ) + cy
        
        let lineLocus1 = Line(x1, y1, x2, y2)
        line1 = Shape(form: lineLocus1, fill: Color.clear, stroke: stroke)
        backgroundLine1 = Shape(form: lineLocus1, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let lineLocus2 = Line(x3, y3, x4, y4)
        line2 = Shape(form: lineLocus2, fill: Color.clear, stroke: stroke)
        backgroundLine2 = Shape(form: lineLocus2, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let lineLocus3 = Line(x5, y5, x6, y6)
        line3 = Shape(form: lineLocus3, fill: Color.clear, stroke: stroke)
        backgroundLine3 = Shape(form: lineLocus3, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        let lineLocus4 = Line(x7, y7, x8, y8)
        line4 = Shape(form: lineLocus4, fill: Color.clear, stroke: stroke)
        backgroundLine4 = Shape(form: lineLocus4, fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 30.0))
        
        contents = [line1, backgroundLine1, line2, backgroundLine2, line3, backgroundLine3, line4, backgroundLine4]
        
        backgroundRect = Shape(form: self.bounds!, fill: Color.clear, stroke: Stroke(fill: Color.blue, width: 2.0))
        
        contents.append(backgroundRect)

    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
    }
    
    func updateStroke(stroke: Stroke) {
        line1.stroke = stroke
        line2.stroke = stroke
        line3.stroke = stroke
        line4.stroke = stroke
    }
    
    func getCenter() -> Point? {
        return line1.bounds?.center()
    }
    
    func setTransformEvents() {
        backgroundRect.onPan { (event) in
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
    }
    
}
