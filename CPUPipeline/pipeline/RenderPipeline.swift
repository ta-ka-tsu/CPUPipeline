//
//  RenderPipeline.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/26.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation
import simd


enum Primitive<T:Blendable> {
    case point(Vertex3<T>)
    case line(Vertex3<T>, Vertex3<T>)
    case triangle(Vertex3<T>, Vertex3<T>, Vertex3<T>)
    
    func isCCW() -> Bool {
        switch self {
        case let .triangle(v1, v2, v3):
            let v12 = v2.position - v1.position
            let v13 = v3.position - v1.position
            return (v12.x * v13.y - v12.y * v13.x < 0.0)// 注意：スクリーン座標系では反時計回りが負になる
        default:
            return true
        }
    }
}

func getDoubleSignedArea(_ p1: float2, _ p2: float2, _ p3: float2) -> Float {
    let vec12 = p2 - p1
    let vec13 = p3 - p1
    return vec12.x * vec13.y - vec12.y * vec13.x
}

func weight<U>(v1: Vertex3<U>, v2: Vertex3<U>, v3: Vertex3<U>, of point:float2) -> (Float, Float, Float)? {
    let p1 = float2(v1.position.x, v1.position.y)
    let p2 = float2(v2.position.x, v2.position.y)
    let p3 = float2(v3.position.x, v3.position.y)
    let doubleTriangleArea = getDoubleSignedArea(p1, p2, p3)
    let inverseOfArea = 1.0/doubleTriangleArea
    if inverseOfArea.isInfinite {
        return nil
    }
    let areaForP12 = getDoubleSignedArea(point, p1, p2)
    let areaForP23 = getDoubleSignedArea(point, p2, p3)
    let areaForP31 = getDoubleSignedArea(point, p3, p1)
    return (inverseOfArea * areaForP23, inverseOfArea * areaForP31, inverseOfArea * areaForP12)
}


class RenderPipeline<T:Blendable, U:Blendable> {
    var vertexBuffer : [Vertex4<T>]!

    var vertexShader : ((Vertex4<T>) -> Vertex4<U>)!
    var fragmentShader : ((Fragment<U>) -> Color4f?)!

    var colorBuffer : ColorBuffer!
    var depthBuffer : DepthBuffer? // 設定されていればデプステストが有効になる
    
    var viewport: Viewport?
    var cullFace = false
    
    let renderingQueue = DispatchQueue(label: "Rendering Queue")
    let lockQueue = DispatchQueue(label: "Lock Queue")
    
    init() {
    }

    private var _isBusy = false
    
    var isBusy : Bool {
        get {
            return lockQueue.sync { _isBusy }
        }
        set {
            lockQueue.sync { _isBusy = newValue }
        }
    }
    
    func rasterize(primitive:Primitive<U>) -> [Fragment<U>] {
        switch primitive {
        case let .point(v1):
            return [Fragment(x: Int(floorf(v1.position.x)), y: Int(floorf(v1.position.y)), z: v1.position.z, attribute: v1.attribute)]
        case let .line(v1, v2):
            return rasterize(v1: v1, v2: v2)
        case let .triangle(v1, v2, v3):
            return rasterize(v1: v1, v2: v2, v3: v3)
        }
    }
    
    func rasterize(v1:Vertex3<U>, v2: Vertex3<U>) -> [Fragment<U>] {
        // TODO
        return []
    }
    
    func rasterize(v1:Vertex3<U>, v2:Vertex3<U>, v3:Vertex3<U>) -> [Fragment<U>] {
        var result = [Fragment<U>]()

        let minX = max(min(min(min(Int(floorf(v1.position.x)), Int(floorf(v2.position.x))), Int(floorf(v3.position.x))), colorBuffer!.width), 0)
        let maxX = min(max(max(max(Int(ceilf(v1.position.x)), Int(ceilf(v2.position.x))), Int(ceilf(v3.position.x))), 0), colorBuffer!.width)
        let minY = max(min(min(min(Int(floorf(v1.position.y)), Int(floorf(v2.position.y))), Int(floorf(v3.position.y))), colorBuffer!.height), 0)
        let maxY = min(max(max(max(Int(ceilf(v1.position.y)), Int(ceilf(v2.position.y))), Int(ceilf(v3.position.y))), 0), colorBuffer!.height)
        
        for py in minY..<maxY {
            for px in minX..<maxX {
                let p = float2(Float(px) + 0.5, Float(py) + 0.5)
                let (w1, w2, w3) = weight(v1: v1, v2: v2, v3: v3, of: p) ?? (-1, -1, -1)
                if w1 < 0 || w2 < 0 || w3 < 0 { continue }
                let eachZ = w1 * v1.position.z + w2 * v2.position.z + w3 * v3.position.z
                let eachAttr = w1 * v1.attribute + w2 * v2.attribute + w3 * v3.attribute
                result.append(Fragment(x: px, y: py, z: eachZ, attribute: eachAttr))
            }
        }
        
        return result;
    }
    
    func drawPrimitives(type: PrimitiveType, completion: (() -> ())? ) {
        if self.isBusy { return }
        self.renderingQueue.async { [weak self] in
            self?.draw(type: type, completion: completion)
        }
    }
    
    private func transform(position:float3, toViewport vp: Viewport) -> float3 {
        let halfWidth = 0.5 * Float(vp.width)
        let halfHeight = 0.5 * Float(vp.height)
        let newX = halfWidth * position.x + Float(vp.x) + halfWidth
        let newY = -halfHeight * position.y + Float(vp.y) + halfHeight
        return float3(newX, newY, position.z)
    }
    
    private func draw(type:PrimitiveType, completion : (() -> ())? ) {
        self.isBusy = true
        defer {
            self.isBusy = false
        }
        self.colorBuffer.clear(with: Color4ui.black)
        self.depthBuffer?.clear(with: 0.0)
        
        let vp = self.viewport ?? Viewport(x: 0, y: 0, width: colorBuffer.width, height: colorBuffer.height)

        // Vertex Processing and Viewport Transformation
        let convertedVertices = vertexBuffer.concurrentMap { (vertex:Vertex4<T>) -> Vertex3<U> in
            let v = vertexShader(vertex)
            
            // divide by w
            let pos = v.position.project()
            
            // Viewport Transformation
            let screenPosition = transform(position: pos, toViewport: vp)
            return Vertex3<U>(position: screenPosition, attribute: v.attribute)
        }
        
        // Primitive Assembly
        var primitives: [Primitive<U>]
        switch type {
        case .points:
            primitives = (0..<convertedVertices.count).map { Primitive<U>.point(convertedVertices[$0]) }
        case .lines:
            let numOfLines = convertedVertices.count / 2
            primitives = (0..<numOfLines)
                .map { Primitive<U>.line(convertedVertices[$0*2], convertedVertices[$0*2 + 1]) }
        case .triangles:
            let numOfTriangles = convertedVertices.count / 3
            primitives = (0..<numOfTriangles).map {
                Primitive<U>.triangle(convertedVertices[$0*3],
                                     convertedVertices[$0*3 + 1],
                                     convertedVertices[$0*3 + 2])
                }.filter { (primitive) -> Bool in
                    if cullFace { return primitive.isCCW() }
                    else { return true }
                }
        }
        
        // Rasterize
        let fragments = primitives.flatMap{ rasterize(primitive: $0) }
        
        // Fragment Processing
        let fragmentResults = fragments.concurrentMap{ (fragment) -> Fragment<Color4f>? in
            if let color = fragmentShader(fragment) {
                return Fragment<Color4f>(x: fragment.x, y: fragment.y, z: fragment.z, attribute: color)
            }
            else {
                return nil
            }
        }.compactMap { $0 }
        
        // Per Sampling Operation
        fragmentResults.forEach { (fragment) in
            if let depthBuffer = depthBuffer {
                if depthBuffer[fragment.x, fragment.y] > fragment.z { return }
                depthBuffer[fragment.x, fragment.y] = fragment.z
            }
            colorBuffer[fragment.x, fragment.y] = fragment.attribute.toColor4ui()
        }
        
        completion?()
    }
}
