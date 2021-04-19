//
//  ParkBenchTimer.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 19/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import CoreFoundation

class ParkBenchTimer {
    
    let startTime:CFAbsoluteTime
    var endTime:CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}
