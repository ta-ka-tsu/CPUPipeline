//
//  DepthBuffer.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/28.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation

class DepthBuffer : BufferPlane {
    let width: Int
    let height: Int
    var buffer: [Float]
    
    init(width:Int, height:Int) {
        self.width = width
        self.height = height
        self.buffer = [Float](repeating: 0.0, count: width * height)
    }
    
    subscript (x : Int, y : Int) -> Float {
        get {
            let offset = y * width + x
            return buffer[offset]
        }
        set {
            buffer[y * width + x] = newValue
        }
    }
}
