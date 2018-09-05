//
//  ColorBuffer.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/24.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import Foundation
import CoreGraphics


class ColorBuffer : BufferPlane {
    static let numberOfComponents = 4 // RGBA
    
    let width: Int
    let height: Int
    var buffer : [UInt8]
    
    init(width:Int, height:Int) {
        self.width = width
        self.height = height;
        self.buffer = [UInt8](repeating: 0, count: ColorBuffer.numberOfComponents * width * height)
    }
    
    init?(fromCGImage image:CGImage?) {
        guard let image = image else {
            return nil
        }
        
        self.width = image.width
        self.height = image.height

        let data = image.dataProvider?.data
        let length = CFDataGetLength(data)
        self.buffer = [UInt8](repeating: 0, count: length)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &self.buffer)
    }
    
    subscript (x : Int, y : Int) -> Color4ui {
        get {
            let offset = (y * width + x) * ColorBuffer.numberOfComponents
            return Color4ui(r: buffer[offset], g: buffer[offset + 1], b: buffer[offset + 2], a: buffer[offset + 3])
        }
        set {
            let offset = (y * width + x) * ColorBuffer.numberOfComponents
            buffer[offset] = newValue.r
            buffer[offset + 1] = newValue.g
            buffer[offset + 2] = newValue.b
            buffer[offset + 3] = newValue.a
        }
    }
    
    func toCGImage() -> CGImage? {
        let bitsPerComponent = 8
        let bitsPerPixel = bitsPerComponent * ColorBuffer.numberOfComponents
        let bytesPerPixel = bitsPerPixel / bitsPerComponent
        
        let dataProvider = CGDataProvider(data : Data(bytes:self.buffer) as CFData)
        return (dataProvider == nil) ? nil :
            CGImage(width: self.width,
                    height: self.height,
                    bitsPerComponent: bitsPerComponent,
                    bitsPerPixel: bitsPerPixel,
                    bytesPerRow: bytesPerPixel * self.width,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: [],
                    provider: dataProvider!,
                    decode: nil,
                    shouldInterpolate: false,
                    intent: .defaultIntent)
    }    
}
