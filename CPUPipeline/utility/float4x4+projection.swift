//
//  float4x4+projection.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/08/19.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation
import simd

extension Float {
    func toRadians() -> Float {
        return self * Float.pi / 180.0
    }
    func toDegrees() -> Float {
        return self * 180.0 / Float.pi
    }
}

extension float4 {
    func project() -> float3 {
        let invW = 1.0/self.w
        return float3(invW * self.x, invW * self.y, invW * self.z)
    }
}

extension float4x4 {
    static func getOrtho(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> float4x4 {
        let inverseOfWidthDiff = 1.0/(right - left)
        let inverseOfHeightDiff = 1.0/(top - bottom)
        let inverseOfDepthDiff = 1.0/(far - near)

        let col1 = float4(2.0*inverseOfWidthDiff, 0.0, 0.0, 0.0)
        let col2 = float4(0.0, 2.0*inverseOfHeightDiff, 0.0, 0.0)
        let col3 = float4(0.0, 0.0, inverseOfDepthDiff, 0.0)
        let col4 = float4(-(right + left)*inverseOfWidthDiff, -(top + bottom)*inverseOfHeightDiff, far*inverseOfDepthDiff, 1.0)
        return float4x4([col1, col2, col3, col4])
    }
    
    static func getTranslation(delta:float3) -> float4x4 {
        let col1 = float4(1.0, 0.0, 0.0, 0.0)
        let col2 = float4(0.0, 1.0, 0.0, 0.0)
        let col3 = float4(0.0, 0.0, 1.0, 0.0)
        let col4 = float4(delta.x, delta.y, delta.z, 1.0)
        return float4x4([col1, col2, col3, col4])
    }
    
    static func getRotationXAxis(degree:Float) -> float4x4 {
        let rad = degree.toRadians()
        let c = cosf(rad)
        let s = sinf(rad)
        
        let col1 = float4(1.0, 0.0, 0.0, 0.0)
        let col2 = float4(0.0, c, s, 0.0)
        let col3 = float4(0.0, -s, c, 0.0)
        let col4 = float4(0.0, 0.0, 0.0, 1.0)
        return float4x4([col1, col2, col3, col4])
    }
    
    static func getRotationYAxis(degree:Float) -> float4x4 {
        let rad = degree.toRadians()
        let c = cosf(rad)
        let s = sinf(rad)
        
        let col1 = float4(c, 0.0, -s, 0.0)
        let col2 = float4(0.0, 1.0, 0.0, 0.0)
        let col3 = float4(s, 0.0, c, 0.0)
        let col4 = float4(0.0, 0.0, 0.0, 1.0)
        return float4x4([col1, col2, col3, col4])
    }
    
    static func getRotationZAxis(degree:Float) -> float4x4 {
        let rad = degree.toRadians()
        let c = cosf(rad)
        let s = sinf(rad)
        
        let col1 = float4(c, s, 0.0, 0.0)
        let col2 = float4(-s, c, 0.0, 0.0)
        let col3 = float4(0.0, 0.0, 1.0, 0.0)
        let col4 = float4(0.0, 0.0, 0.0, 1.0)
        return float4x4([col1, col2, col3, col4])
    }
}
