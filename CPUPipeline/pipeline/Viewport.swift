//
//  Viewport.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/27.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation

class Viewport {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}
