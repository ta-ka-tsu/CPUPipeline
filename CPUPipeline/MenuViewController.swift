//
//  MenuViewController.swift
//  CPUPipeline
//
//  Created by TakatsuYouichi on 2018/08/26.
//  Copyright © 2018年 TakatsuYouichi. All rights reserved.
//

import UIKit
import simd

struct Attribute : Blendable {
    var color: Color4f
    var texCod: float2
    var normal: float3
    
    static func + (lhs: Attribute, rhs: Attribute) -> Attribute {
        return Attribute(color: lhs.color + rhs.color, texCod: lhs.texCod + rhs.texCod, normal: lhs.normal + rhs.normal)
    }
    
    static func * (scale: Float, value: Attribute) -> Attribute {
        return Attribute(color: scale * value.color, texCod: scale * value.texCod, normal: scale * value.normal)
    }
}

struct DataSource {
    var title:String
    var vertices:[Vertex4<Attribute>]
    var fragmentShader:((Fragment<Attribute>)->Color4f)
    var texture: ColorBuffer?
}

func sample(texture:ColorBuffer, cod:float2) -> Color4f {
    let cod = min(float2(1.0, 1.0), max(float2(0.0, 0.0), cod))
    let px = Int(cod.x * Float(texture.width - 1))
    let py = Int((1.0 - cod.y) * Float(texture.height - 1))
    let color = texture[px, py]
    return Color4f(r: Float(color.r)/255.0, g: Float(color.g)/255.0, b: Float(color.b)/255.0, a: 1.0)
}

// light
let light = normalize(float3(1.0, 1.0, 1.0))
let ambient: Float = 0.5
let diffuse: Float = 0.5
// Textures
var wallTexture = ColorBuffer(fromCGImage: UIImage(named: "mauerwerk_0030_c.jpg")?.cgImage)!
var metalTexture = ColorBuffer(fromCGImage: UIImage(named: "hotspot.png")?.cgImage)!
var metalTexture2 = ColorBuffer(fromCGImage: UIImage(named: "Warmth3.png")?.cgImage)!

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var dataSources = [DataSource]()
    
    // Data Sources
    var triangle = [Vertex4(position: float4(0.0, 1.0, 1.0, 1.0), attribute: Attribute(color: Color4f.red, texCod: float2(0.5, 1.0), normal: float3())),
                    Vertex4(position: float4(-1.0, -1.0, 1.0, 1.0), attribute: Attribute(color: Color4f.green, texCod: float2(0.0, 0.0), normal: float3())),
                    Vertex4(position: float4(1.0, -1.0, 1.0, 1.0), attribute: Attribute(color: Color4f.blue, texCod: float2(1.0, 0.0), normal: float3()))]
    var uthaTeapotSmooth = ObjReader(url: Bundle.main.url(forResource: "wt_teapot", withExtension: "obj")!)!.getVertices()

    // context
    static var currentTexture: ColorBuffer?
    
    // Fragment Shaders
    var simpleColorFragment = { (fragment:Fragment<Attribute>) -> Color4f in
        return fragment.attribute.color
    }
    var lightingFragment = { (fragment:Fragment<Attribute>) -> Color4f in
        // 照光処理
        let normal = normalize(fragment.attribute.normal)
        let intensity = diffuse * dot(light, normal) + ambient
        return Color4f(r: intensity, g: intensity, b: intensity, a: 1.0)
    }
    var textureMappingFragment = { (fragment:Fragment<Attribute>) -> Color4f in
        return sample(texture: currentTexture!, cod: fragment.attribute.texCod)
    }
    var matcapFragment = { (fragment:Fragment<Attribute>) -> Color4f in
        let normalizedNormal = normalize(fragment.attribute.normal)
        let uvPos = float2(0.5 * normalizedNormal.x + 0.5, 0.5 * normalizedNormal.y + 0.5)
        return sample(texture: currentTexture!, cod: uvPos)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSources.append(DataSource(title: "Hello Triangle", vertices: self.triangle, fragmentShader: lightingFragment, texture: nil))
        dataSources.append(DataSource(title: "Rasterize Test", vertices: self.triangle, fragmentShader: simpleColorFragment, texture: nil))
        dataSources.append(DataSource(title: "Texture Mapping", vertices: self.triangle, fragmentShader: textureMappingFragment, texture: wallTexture))
        dataSources.append(DataSource(title: "Utah Teapot", vertices: self.uthaTeapotSmooth, fragmentShader: lightingFragment, texture: nil))
        dataSources.append(DataSource(title: "Utah Teapot(MatCap 1)", vertices: self.uthaTeapotSmooth, fragmentShader: matcapFragment, texture: metalTexture))
        dataSources.append(DataSource(title: "Utah Teapot(MatCap 2)", vertices: self.uthaTeapotSmooth, fragmentShader: matcapFragment, texture: metalTexture2))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let vc = segue.destination as? ViewController else {
            return
        }
        vc.pipeline.vertexBuffer = dataSources[selected].vertices
        vc.pipeline.fragmentShader = dataSources[selected].fragmentShader
        MenuViewController.currentTexture = dataSources[selected].texture
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")!
        cell.textLabel?.text = dataSources[indexPath.row].title
        
        return cell
    }
    
    var selected : Int = 0
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selected = indexPath.row
        self.performSegue(withIdentifier: "displaySegue", sender: self)
    }
}
