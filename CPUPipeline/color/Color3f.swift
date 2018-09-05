//
//  Color3f.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/28.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation

struct Color3f: Blendable {
    let r : Float
    let g : Float
    let b : Float
}

extension Color3f {
    static func +(lhs: Color3f, rhs: Color3f) -> Color3f {
        return Color3f(r: lhs.r + rhs.r, g: lhs.g + rhs.g, b: lhs.b + rhs.b)
    }
    
    static func *(scale: Float, value: Color3f) -> Color3f {
        return Color3f(r: scale * value.r, g: scale * value.g, b: scale * value.b)
    }
}

// convert
extension Color3f {
    // clip between 0.0 and 1.0
    func clipped() -> Color3f {
        let r = max(0.0, min(1.0, self.r))
        let g = max(0.0, min(1.0, self.g))
        let b = max(0.0, min(1.0, self.b))
        return Color3f(r: r, g: g, b: b)
    }
    
    func toColor3ui() -> Color3ui {
        let clipped = self.clipped()
        return Color3ui(r: UInt8(255 * clipped.r), g: UInt8(255 * clipped.g), b: UInt8(255 * clipped.b))
    }
}

extension Color3f {
    static let red = Color3f(r: 1.0, g: 0, b: 0)
    static let green = Color3f(r: 0, g: 1.0, b: 0)
    static let blue = Color3f(r: 0, g: 0, b: 1.0)
    static let white = Color3f(r: 1.0, g: 1.0, b: 1.0)
    static let black = Color3f(r: 0, g: 0, b: 0)
}
