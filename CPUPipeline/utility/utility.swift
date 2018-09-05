//
//  utility.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/08/20.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation
import simd

struct Sphere {
    var center : float3
    var radius : Float
}

func getBoundingSphere<T>(of vertices:[Vertex4<T>]) -> Sphere {
    var minPos = float3(Float.infinity, Float.infinity, Float.infinity)
    var maxPos = float3(-Float.infinity, -Float.infinity, -Float.infinity)
    vertices.forEach { vertex in
        minPos = min(minPos, vertex.position.project())
        maxPos = max(maxPos, vertex.position.project())
    }
    return Sphere(center: 0.5 * (minPos + maxPos), radius: 0.5 * distance(minPos, maxPos))
}


extension Array {
    func concurrentMap<B>(_ transform: (Element) -> B) -> [B] {
        var result = ContiguousArray<B?>(repeating: nil, count: count)
        return result.withUnsafeMutableBufferPointer { buffer in
            DispatchQueue.concurrentPerform(iterations: 2) { idx in
                let taskCount = count / 2
                let (from, to) = (idx == 0) ? (0, taskCount) : (taskCount, count)
                for i in from..<to {
                    buffer[i] = transform(self[i])
                }
            }
            return buffer.map { $0! }
        }
    }
}
