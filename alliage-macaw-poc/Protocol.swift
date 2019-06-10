//
//  Protocol.swift
//  alliage-macaw-poc
//
//  Created by Vitor Muniz on 04/06/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import Foundation
import Macaw

protocol DrawElement {}

protocol DrawElementFactory {
    func createDrawElement() -> DrawElement?
}

protocol Canvas {
    associatedtype ToolSet where ToolSet:DrawElementFactory
    func loadContext(_ context: Data)
    func exportContext() -> Data
    var selectTool: ToolSet { get set }
    
    func redo()
    func undo()
    func clearAll()
}

class AnnotationArea: Canvas {
    
    typealias T = ToolSet
    
    var selectTool: AnnotationArea.ToolSet = .rect(strokeWidth: 1) {
        didSet {
            
        }
    }

    func loadContext(_ context: Data) {
        
    }

    func exportContext() -> Data {
        return Data()
    }
    
    
    func redo() {
        
    }
    
    func undo() {
        
    }
    
    func clearAll() {
        
    }

}

extension AnnotationArea{
    enum ToolSet: DrawElementFactory {
        
        case rect(strokeWidth: Double)
        case circle(strokeWidth: Double)
        case arrow(strokeWidth: Double)
        case textArea((String) -> Void, font: CGFont)
        case none
        func createDrawElement() -> DrawElement? {
            return nil
        }
        
    }
}

