//
//  ViewController.swift
//  MetalMacOS
//
//  Created by Олег Попов on 30.05.2022.
//

import MetalKit

class ViewController: NSViewController {
    let metalView = MTKView()
    let renderer = Renderer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(metalView)
        metalView.delegate = renderer
        metalView.device = renderer.device
        metalView.clearColor = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    }
    
    override func viewDidLayout(){
        super.viewDidLayout()
        metalView.frame = self.view.bounds
    }
    override var representedObject: Any? {
        didSet {
            
        }
    }
}

final class Renderer: NSObject {
    let device = MTLCreateSystemDefaultDevice()!
    let queue: MTLCommandQueue
    var renderPipelineState: MTLRenderPipelineState!
    let meshBuffer: MTLBuffer
    let vertexUniformsBuffer: MTLBuffer
    
    let mesh: [VertexIn] = [
        VertexIn(pos: [0.0, 1.0, 0.0], color: [1.0, 1.0, 1.0]),
        VertexIn(pos: [-1.0, -1.0, 0.0], color: [0.0, 0.0, 1.0]),
        VertexIn(pos: [1.0, -1.0, 0.0], color: [1.0, 0.0, 0.0])
    ]
    
    override init() {
        queue = device.makeCommandQueue()!
        meshBuffer = device.makeBuffer(bytes: mesh, length: MemoryLayout<VertexIn>.stride * mesh.count, options: .storageModeShared)!
        self.vertexUniformsBuffer = device.makeBuffer(length: MemoryLayout<VertexUniforms>.stride, options: .storageModeShared)!
        super.init()
        renderPipelineState = self.makeRenderPipelineState()
    }
    
    private func makeRenderPipelineState() -> MTLRenderPipelineState {
        let lib = device.makeDefaultLibrary()
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = lib?.makeFunction(name: "vertex_main")
        descriptor.fragmentFunction = lib?.makeFunction(name: "fragment_main")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        return try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    private func makeRotationMatrix(angle: Float) -> simd_float3x3 {
        return simd_float3x3(rows: [
        [cos(angle), -sin(angle), 0],
        [sin(angle),  cos(angle), 0],
        [0         ,  0         , 1]
        ])
    }
    
    var lastRenderTime: TimeInterval! = nil
    var currentTime: TimeInterval = 0.0
    
    var rotationAngle: Double = 0
}

extension Renderer: MTKViewDelegate {
    func update(deltaTime: TimeInterval) {
        rotationAngle = rotationAngle + (0.1 * Double.pi - 0) * deltaTime
        let rotationMatrix = makeRotationMatrix(angle: Float(rotationAngle))
        var vertexUniforms = VertexUniforms(modelMatrix: rotationMatrix)
        
        memcpy(vertexUniformsBuffer.contents(), &vertexUniforms, MemoryLayout<VertexUniforms>.stride)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //
    }
    func draw(in view: MTKView) {
        let systemTime = CACurrentMediaTime()
        let deltaTime = (lastRenderTime == nil) ? 0 : (systemTime - lastRenderTime!)
        lastRenderTime = systemTime
        
        update(deltaTime: deltaTime)
        
        guard let drawable = view.currentDrawable,
              let passDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = queue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        else { return }
        
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        renderEncoder.setVertexBuffer(meshBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: mesh.count)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    
}
