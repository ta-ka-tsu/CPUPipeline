//
//  Blendable.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/27.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation
import simd

protocol Blendable : Addable, Scalable {
}

extension Blendable {
    static func -(lhs:Self, rhs:Self) -> Self {
        return lhs + (-1) * rhs
    }
    
    static prefix func -(val:Self) -> Self {
        return (-1) * val
    }
}
