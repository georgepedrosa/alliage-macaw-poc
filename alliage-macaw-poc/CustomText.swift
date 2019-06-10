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
    
    var text: Text!
    
    required init(startPoint: Point, lastPoint: Point) {
        
    }
    
    init(text: String, startPoint: Point) {
        self.text.text = text
    }
    
    func updateForm(startPoint: Point, lastPoint: Point) {
        
    }
    
    func updateStroke(stroke: Stroke) {
        
    }
    
    func getCenter() -> Point? {
        return nil
    }
    
    func activateCircleAction() {
        
    }

}
