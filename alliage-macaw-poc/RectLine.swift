//
//  RectLine.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 05/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class RectLine: Group {
    
    var line: Shape!
    var rect: Shape!
    
    init(startPoint: Point, lastPoint: Point) {
        super.init()
        let locusLine = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        line = Shape(form: locusLine, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        let width = lastPoint.x - startPoint.x
        let height = lastPoint.y - startPoint.y
        let locusRect = Rect(x: startPoint.x, y: startPoint.y, w: width, h: height)
        rect = Shape(form: locusRect, fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        contents = [line, rect]
    }
    
    func changeShape(startPoint: Point, lastPoint: Point) {
        self.line.form = Line(startPoint.x, startPoint.y, lastPoint.x, lastPoint.y)
        self.rect.form = Rect(x: startPoint.x, y: startPoint.y, w: lastPoint.x - startPoint.x, h: lastPoint.y - startPoint.y)
    }
    
}
