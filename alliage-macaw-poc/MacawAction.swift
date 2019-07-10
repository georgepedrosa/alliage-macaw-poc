//
//  MacawAction.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 05/07/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import Foundation

class MacawAction {
    
    var nodeHash: Int!
    var type: ActionType!
    var transformation: (dx:Double,dy:Double,scale:Double,angle:Double)?
    
    init(nodeHash: Int, type: ActionType, transformation: (dx:Double,dy:Double,scale:Double,angle:Double)? = nil){
        self.nodeHash = nodeHash
        self.type = type
        self.transformation = transformation
    }
}

enum ActionType {
    case create
    case pan
    case pinch
}
