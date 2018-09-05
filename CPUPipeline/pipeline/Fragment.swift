//
//  Fragment.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/27.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation
import simd

class Fragment<T:Blendable> {
    let x: Int
    let y: Int
    let z: Float
    let attribute: T
    
    init(x:Int, y: Int, z:Float, attribute: T) {
        self.x = x
        self.y = y
        self.z = z
        self.attribute = attribute
    }
}
