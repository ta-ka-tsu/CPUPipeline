//
//  ViewController.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/06/15.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import UIKit
import QuartzCore
import simd

class PlatingMetalLayer : CALayer {
    override init() {
        super.init()
//        super.contentsFormat
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    var scaleFactor:CGFloat = UIScreen.main.scale

    var modelMat = float4x4(1.0)
    var viewMat = float4x4(1.0)
    var backViewMat = float4x4(1.0)
    var projMat = float4x4(1.0)
    let pipeline = RenderPipeline<Attribute,Attribute>()
    
    var renderPrimitive = PrimitiveType.triangles
    
    // timer
    var displayLink: CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let bsphere = getBoundingSphere(of: self.pipeline.vertexBuffer)

        // matrices
        self.modelMat = float4x4.getTranslation(delta: -bsphere.center)
        let aspect = Float(self.view.frame.width/self.view.frame.height)
        let viewheight:Float = (aspect > 1.0) ? bsphere.radius : bsphere.radius/aspect
        self.projMat = float4x4.getOrtho(left: -aspect*viewheight, right: aspect*viewheight, bottom: -viewheight, top: viewheight, near: -bsphere.radius, far: bsphere.radius)
        
        // Setup Renderpipeline
        pipeline.cullFace = true
        pipeline.vertexShader = { [weak self](vertex) -> Vertex4<Attribute> in
            guard let `self` = self else { return Vertex4(position: float4(), attribute: Attribute(color: .black, texCod: float2(), normal: float3())) }
            
            let modelViewMat = self.viewMat * self.modelMat
            let pos = self.projMat * (modelViewMat * vertex.position)
            let normal = modelViewMat * float4(vertex.attribute.normal.x, vertex.attribute.normal.y, vertex.attribute.normal.z, 0.0)
            return Vertex4<Attribute>(position: pos, attribute: Attribute(color: vertex.attribute.color, texCod: vertex.attribute.texCod, normal: float3(normal.x, normal.y, normal.z)))
        }
        
        let tapGestureRecognizer :UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ViewController.onTapAction(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        let doubleTapGestureRecognizer :UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ViewController.onDoubleTapAction(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(doubleTapGestureRecognizer)
        
        let panGestureRecognizer : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.onPanAction(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        // setup display link
        self.displayLink = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))
        self.displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
        self.displayLink.isPaused = true
    }
    
    func render() {
        self.pipeline.drawPrimitives(type: self.renderPrimitive) { [weak self] in
            if let `self` = self {
                DispatchQueue.main.async {
                    self.view.layer.contents = self.pipeline.colorBuffer.toCGImage()
                }
                self.viewMat = self.backViewMat
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = Int(self.view.frame.width * self.scaleFactor)
        let height = Int(self.view.frame.height * self.scaleFactor)

        self.pipeline.colorBuffer = ColorBuffer(width: width, height: height)
        self.pipeline.depthBuffer = DepthBuffer(width: width, height: height)
        // 一度レンダリングしておく
        self.render()
    }
    
    @objc func newFrame(displayLink:CADisplayLink) {
        self.render()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func changeDrawType() {
        switch renderPrimitive {
        case .points:
            renderPrimitive = .triangles
        case .triangles:
            renderPrimitive = .points
        default:
            break
        }
    }
    
    private func close() {
        self.displayLink.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onTapAction(_ sender :UITapGestureRecognizer) {
        changeDrawType()
    }
    
    @objc func onDoubleTapAction(_ sender :UITapGestureRecognizer) {
        close()
    }
    
    var previousTranslation:CGPoint = CGPoint.zero
    @objc func onPanAction(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let delta = float2(Float(translation.x - self.previousTranslation.x), Float(translation.y - self.previousTranslation.y))
        
        let lengthOfDelta = length(delta)
        // ディスプレイ座標系のYが逆向きなのを考慮すると回転軸の向きは(delta.y, delta.x)
        let axisAngle = atan2(delta.x, delta.y).toDegrees()
        let rot = float4x4.getRotationZAxis(degree: axisAngle) * float4x4.getRotationXAxis(degree: lengthOfDelta) * float4x4.getRotationZAxis(degree: -axisAngle)
        switch sender.state {
        case .began:
            self.previousTranslation = translation
            self.displayLink.isPaused = false
        case .ended:
            self.backViewMat = rot * self.backViewMat
            self.render()
            self.previousTranslation = CGPoint.zero
            self.displayLink.isPaused = true
        case .changed:
            self.backViewMat = rot * self.backViewMat
            self.render()
            self.previousTranslation = translation
        default:
            break
        }
    }
}

