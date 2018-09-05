//
//  Color4ui.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/08/18.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation

struct Color4ui {
    let r : UInt8
    let g : UInt8
    let b : UInt8
    let a : UInt8
}

extension Color4ui {
    static let red = Color4ui(r: 255, g: 0, b: 0, a: 255)
    static let green = Color4ui(r: 0, g: 255, b: 0, a: 255)
    static let blue = Color4ui(r: 0, g: 0, b: 255, a: 255)
    static let white = Color4ui(r: 255, g: 255, b: 255, a:255)
    static let black = Color4ui(r: 0, g: 0, b: 0, a: 255)
}

extension Color4ui {
    func description() -> String {
        return "(R, G, B, A) = (\(self.r), \(self.g), \(self.b), \(self.a))"
    }
}
