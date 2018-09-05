//
//  Color4f.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/28.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation

struct Color4f : Blendable {
    let r: Float
    let g: Float
    let b: Float
    let a: Float
}

extension Color4f {
    static func +(lhs: Color4f, rhs: Color4f) -> Color4f {
        return Color4f(r: lhs.r + rhs.r, g: lhs.g + rhs.g, b: lhs.b + rhs.b, a: lhs.a + rhs.a)
    }
    
    static func *(scale: Float, value: Color4f) -> Color4f {
        return Color4f(r: scale * value.r, g: scale * value.g, b: scale * value.b, a: scale * value.a)
    }
}

// convert
extension Color4f {
    // clip between 0.0 and 1.0
    func clipped() -> Color4f {
        let r = max(0.0, min(1.0, self.r))
        let g = max(0.0, min(1.0, self.g))
        let b = max(0.0, min(1.0, self.b))
        let a = max(0.0, min(1.0, self.a))
        return Color4f(r: r, g: g, b: b, a: a)
    }
    
    func toColor4ui() -> Color4ui {
        let clipped = self.clipped()
        return Color4ui(r: UInt8(255 * clipped.r), g: UInt8(255 * clipped.g), b: UInt8(255 * clipped.b), a: UInt8(255 * clipped.a))
    }
}

extension Color4f {
    static let red = Color4f(r: 1.0, g: 0.0, b: 0.0, a: 1.0)
    static let green = Color4f(r: 0.0, g: 1.0, b: 0.0, a: 1.0)
    static let blue = Color4f(r: 0.0, g: 0.0, b: 1.0, a: 1.0)
    static let white = Color4f(r: 1.0, g: 1.0, b: 1.0, a:1.0)
    static let black = Color4f(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
}
