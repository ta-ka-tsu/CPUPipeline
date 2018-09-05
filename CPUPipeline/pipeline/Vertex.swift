//
//  Vertex.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/27.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation
import simd

class Vertex3<T:Blendable> {
    var position : float3
    var attribute : T
    
    init(position:float3, attribute:T) {
        self.position = position
        self.attribute = attribute
    }
}

class Vertex4<T:Blendable> {
    var position : float4
    var attribute : T
    
    init(position:float4, attribute:T) {
        self.position = position
        self.attribute = attribute
    }
}
