//
//  Arrow.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 05/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

import UIKit
import Macaw

class Arrow: Group {
    
    var line: Shape!
    var headLeft: Shape!
    var headRight: Shape!
    
    init(startPoint: Point, lastPoint: Point) {
        super.init()
        let lineLocus = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        line = Shape(form: lineLocus, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        
        let x1 = startPoint.x
        let y1 = startPoint.y
        
        let x2 = lastPoint.x
        let y2 = lastPoint.y
        
        let l1 = max(distance(startPoint, lastPoint),0.005)
        let l2 = l1/10
        
        let x3 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(0.78) ) + ( (y1-y2) * (sin(0.78) ) ) ) )
        let y3 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(0.78) ) - ( (x1-x2) * (sin(0.78) ) ) ) )
        let x4 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(0.78) ) - ( (y1-y2) * (sin(0.78) ) ) ) )
        let y4 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(0.78) ) + ( (x1-x2) * (sin(0.78) ) ) ) )
        
        let headLeftLocus = Line(x1: x2, y1: y2, x2: x3, y2: y3)
        let headRightLocus = Line(x1: x2, y1: y2, x2: x4, y2: y4)
        
        headLeft = Shape(form: headLeftLocus, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        headRight = Shape(form: headRightLocus, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        
        contents = [line, headLeft, headRight]
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        
        let x1 = startPoint.x
        let y1 = startPoint.y
        
        let x2 = lastPoint.x
        let y2 = lastPoint.y
        
        let l1 = distance(startPoint, lastPoint)
        let l2 = l1/10
        
        let x3 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(0.78) ) + ( (y1-y2) * (sin(0.78) ) ) ) )
        let y3 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(0.78) ) - ( (x1-x2) * (sin(0.78) ) ) ) )
        let x4 = x2 + ( (l2/l1) * ( ( (x1-x2) * cos(0.78) ) - ( (y1-y2) * (sin(0.78) ) ) ) )
        let y4 = y2 + ( (l2/l1) * ( ( (y1-y2) * cos(0.78) ) + ( (x1-x2) * (sin(0.78) ) ) ) )
        
        let headLeftLocus = Line(x1: x2, y1: y2, x2: x3, y2: y3)
        let headRightLocus = Line(x1: x2, y1: y2, x2: x4, y2: y4)
        
        self.line.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        self.headLeft.form = headLeftLocus
        self.headRight.form = headRightLocus
    }
    
    func distance(_ a: Point, _ b: Point) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
}
