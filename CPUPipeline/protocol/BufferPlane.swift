//
//  BufferPlane.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/27.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation

protocol BufferPlane {
    associatedtype CellType
    
    var width: Int { get }
    var height: Int { get }
    
    subscript(x: Int, y: Int) -> CellType { get set }
}

extension BufferPlane {
    mutating func clear(with value:CellType) {
        for i in 0 ..< width {
            for j in 0 ..< height {
                self[i, j] = value
            }
        }
    }
}
