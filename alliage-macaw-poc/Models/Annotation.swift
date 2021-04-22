//
//  Annotation.swift
//  Alliage
//
//  Created by George Pedrosa on 16/09/19.
//  Copyright © 2019 LDS. All rights reserved.
//

import Foundation

struct Annotation {
        
    let tipo_anotacao: String?
    let pos_inicial_x_anotacao: Double?
    let pos_inicial_y_anotacao: Double?
    let pos_meio_x_anotacao: [Double]?
    let pos_meio_y_anotacao: [Double]?
    let pos_final_x_anotacao: Double?
    let pos_final_y_anotacao: Double?
    let cor_anotacao: String?
    let espessura_anotacao: Double?
    let texto_anotacao: String?
    let descricao_anotacao: String?
}

extension Annotation {
    
    enum Types: String, CustomStringConvertible, CaseIterable {
        
        case rect = "RETANGULO"
        case line = "LINHA"
        case ellipse = "ELIPSE"
        case arrow = "SETA"
        case asterisk = "ASTERISCO"
        case arc = "CURVA"
        case freeDrawing = "DESENHO"
        case protractor = "ANGULO"
        case multiline = "MULTIPLAS_DISTANCIAS"
        case text = "TEXTO"
        case none = "OUTRO"
        
        var iconName: String {
            switch self {
            case .rect:
                return "square"
            case .line:
                return "line"
            case .ellipse:
                return "circle"
            case .arrow:
                return "arrow"
            case .asterisk:
                return "asterisk"
            case .arc:
                return "arc"
            case .freeDrawing:
                return "drawing"
            case .protractor:
                return "protractor"
            case .multiline:
                return "multiline"
            case .text:
                return "text"
            case .none:
                return ""
            }
        }
        
        var description: String {
            switch self {
            case .rect:
                return "RECTANGLE"
            case .line:
                return "LINE"
            case .ellipse:
                return "ELLIPSE"
            case .arrow:
                return "ARROW"
            case .asterisk:
                return "ASTERISK"
            case .arc:
                return "ARC"
            case .freeDrawing:
                return "DRAWING"
            case .protractor:
                return "ANGLE"
            case .multiline:
                return "MULTILINE"
            case .text:
                return "TEXT"
            case .none:
                return "OTHER"
            }
        }
    }
    
    var tipoAnotacao: Annotation.Types {
        return Annotation.Types(rawValue: self.tipo_anotacao!) ?? .none
    }
    
    var posInicialX: Double {
        return self.pos_inicial_x_anotacao!
    }
    
    var posInicialY: Double {
        return self.pos_inicial_y_anotacao!
    }
    
    var posMeioX: [Double] {
        return self.pos_meio_x_anotacao!
    }
    
    var posMeioY: [Double] {
        return self.pos_meio_y_anotacao!
    }
    
    var posFinalX: Double {
        return self.pos_final_x_anotacao!
    }
    
    var posFinalY: Double {
        return self.pos_final_y_anotacao!
    }
    
    var espessura: Double {
        return self.espessura_anotacao!
    }
    
    var corAnotacao: [Int] {
        let string = self.cor_anotacao!
        
        var colors: [Int] = []
        let colorsStringArr = string.components(separatedBy: "&")
        for colorString in colorsStringArr {
            let string = colorString.dropFirst().dropFirst().dropLast().dropLast()
            colors.append(Int(string, radix: 16)!)
        }
        return colors
    }
}
