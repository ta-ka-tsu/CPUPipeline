//
//  Color.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/24.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation

struct Color3ui {
    let r : UInt8
    let g : UInt8
    let b : UInt8
}

extension Color3ui {
    static let red = Color3ui(r: 255, g: 0, b: 0)
    static let green = Color3ui(r: 0, g: 255, b: 0)
    static let blue = Color3ui(r: 0, g: 0, b: 255)
    static let white = Color3ui(r: 255, g: 255, b: 255)
    static let black = Color3ui(r: 0, g: 0, b: 0)
}

extension Color3ui {
    func description() -> String {
        return "(R, G, B) = (\(self.r), \(self.g), \(self.b))"
    }
}
