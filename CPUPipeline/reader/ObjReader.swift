//
//  ObjReader.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/08/19.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation
import simd

struct Face {
    let v1: Int
    let v2: Int
    let v3: Int
}

class ObjReader {
    private var points = [float4]()
    private var normals = [float3]()
    private var texCods = [float2]()
    
    struct VertexIndicator {
        var pointIndex:Int
        var texCodIndex:Int?
        var normalIndex:Int?
    }
    
    struct Face {
        var v1: VertexIndicator
        var v2: VertexIndicator
        var v3: VertexIndicator
    }
    private var faces = [Face]()
    
    init?(url:URL) {
        var data:String
        do {
            data = try String(contentsOf: url, encoding: .utf8)
        } catch {
            return nil
        }
        let lines = data.components(separatedBy: .newlines)
        lines.forEach {
            self.parseLine(line: $0)
        }
    }
    
    func getVertices() -> [Vertex4<Attribute>] {
        return faces.map{ [getVertex(indicator: $0.v1), getVertex(indicator: $0.v2), getVertex(indicator: $0.v3)] }.flatMap{ $0 }
    }
    
    func getFlatVertices() -> [Vertex4<Attribute>] {
        return faces.map{ (face) -> [Vertex4<Attribute>] in
            let v1 = getVertex(indicator: face.v1)
            let v2 = getVertex(indicator: face.v2)
            let v3 = getVertex(indicator: face.v3)
            let normal = normalize(cross(v2.position.project() - v1.position.project(), v3.position.project() - v1.position.project()))
            let newV1 = Vertex4<Attribute>(position:v1.position, attribute: Attribute(color: v1.attribute.color, texCod: v1.attribute.texCod, normal: normal))
            let newV2 = Vertex4<Attribute>(position:v2.position, attribute: Attribute(color: v2.attribute.color, texCod: v2.attribute.texCod, normal: normal))
            let newV3 = Vertex4<Attribute>(position:v3.position, attribute: Attribute(color: v3.attribute.color, texCod: v3.attribute.texCod, normal: normal))
            return [newV1, newV2, newV3]
        }.flatMap{ $0 }
    }
    
    private func getVertex(indicator:VertexIndicator) -> Vertex4<Attribute> {
        let position = points[indicator.pointIndex - 1]
        let texCod = indicator.texCodIndex == nil ? float2() : texCods[indicator.texCodIndex! - 1]
        let normal = indicator.normalIndex == nil ? float3() : normals[indicator.normalIndex! - 1]
        return Vertex4(position: position, attribute: Attribute(color: Color4f.white, texCod: texCod, normal: normal))
    }
    
    private func parseLine(line:String) {
        if line.hasPrefix("#") {
            return
        }
        
        let elements = line.components(separatedBy: " ")
        guard elements.isEmpty == false else {
            return
        }
        
        let firstElement = elements[0]
        if firstElement == "v" {
            parsePoint(elem: elements)
        }
        else if firstElement == "vt" {
            parseTexCod(elem: elements)
        }
        else if firstElement == "vn" {
            parseNormal(elem: elements)
        }
        else if firstElement == "f" {
            parseFace(elem: elements)
        }
        else {
            return
        }
    }
    
    private func parsePoint(elem:[String]) {
        guard elem.count >= 4 else {
            return
        }
        
        var point = float4()
        if let x = Float(elem[1]) {
            point.x = x
        }
        else {
            return
        }
        
        if let y = Float(elem[2]) {
            point.y = y
        }
        else {
            return
        }
        
        if let z = Float(elem[3]) {
            point.z = z
        }
        else {
            return
        }
        
        if elem.count >= 5 {
            if let w = Float(elem[4]) {
                point.w = w
            }
            else {
                return
            }
        }
        else {
            point.w = 1.0
        }
        
        self.points.append(point)
    }
    
    private func parseTexCod(elem:[String]) {
        guard elem.count >= 3 else {
            return
        }
        
        var texCod = float2()
        if let x = Float(elem[1]) {
            texCod.x = x
        }
        else {
            return
        }
        
        if let y = Float(elem[2]) {
            texCod.y = y
        }
        else {
            return
        }
        
        self.texCods.append(texCod)
    }
    
    private func parseNormal(elem:[String]) {
        guard elem.count == 4 else {
            return
        }
        
        var normal = float3()
        if let x = Float(elem[1]) {
            normal.x = x
        }
        else {
            return
        }
        
        if let y = Float(elem[2]) {
            normal.y = y
        }
        else {
            return
        }
        
        if let z = Float(elem[3]) {
            normal.z = z
        }
        else {
            return
        }
        
        self.normals.append(normal)
    }
    
    private func parseFace(elem:[String]) {
        guard elem.count == 4 else {
            return
        }
        
        if let v1 = parseVertex(str: elem[1]), let v2 = parseVertex(str: elem[2]), let v3 = parseVertex(str: elem[3]) {
            let face = Face(v1: v1, v2: v2, v3: v3)
            self.faces.append(face)
        }
    }
    
    private func parseVertex(str:String) -> VertexIndicator? {
        let indices = str.components(separatedBy: "/")
        if indices.count == 1 {
            if let pointIndex = Int(indices[0]) {
                return VertexIndicator(pointIndex: pointIndex, texCodIndex: nil, normalIndex: nil)
            }
            else {
                return nil
            }
        }
        else if indices.count == 2 {
            guard let pointIndex = Int(indices[0]) else {
                return nil
            }
            let texCodIndex = Int(indices[1])
            return VertexIndicator(pointIndex: pointIndex, texCodIndex: texCodIndex, normalIndex: nil)
        }
        else if indices.count == 3 {
            guard let pointIndex = Int(indices[0]) else {
                return nil
            }
            let texCodIndex = Int(indices[1])
            let normalIndex = Int(indices[2])
            return VertexIndicator(pointIndex: pointIndex, texCodIndex: texCodIndex, normalIndex: normalIndex)
        }
        else {
            return nil
        }
    }
}
