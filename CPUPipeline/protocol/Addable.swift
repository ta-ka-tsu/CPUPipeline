//
//  Addable.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/27.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation

protocol Addable {
    static func +(lhs:Self, rhs:Self) -> Self
}
