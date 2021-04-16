//
//  BaseModel.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 15/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import Foundation

protocol BaseModel: Codable {
    static var tableName: String { get }
    var id: Int? { get }
}

