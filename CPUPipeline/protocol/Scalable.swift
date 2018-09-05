//
//  Scalable.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/27.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation

protocol Scalable {
    static func *(scale:Float, value:Self) -> Self
}

extension Scalable {
    static func *(value:Self, scale:Float) -> Self {
        return scale * value
    }
    
    static func /(value:Self, div:Float) -> Self {
        return (1.0/div) * value
    }
}
