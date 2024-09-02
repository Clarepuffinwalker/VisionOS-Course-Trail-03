//
//  ContentView.swift
//  VisionOS Course Trail 03
//
//  Created by ClareZhou on 2024/9/2.
//

import SwiftUI
import RealityKit
import RealityKitContent

//TODO: 1. 应该将模型放入 RealityKitContent 再load，但这样不能直接load模型为ModelEntity，只能Entity，再去相应找 ModelComponent 设置，后续再设置吧，先直接文件夹 load 模型；
//TODO: 2.

struct ContentView: View {
    
    @State private var modelEntity: ModelEntity?
    @State private var slideLong: ModelEntity = ModelEntity()
    @State private var scene: ModelEntity = ModelEntity()
    @State private var ball: ModelEntity = ModelEntity()

    var body: some View {
        VStack{
            RealityView { content in
                // 所有模型的碰撞和输入组件在RCP里已经设置过了
                // Ball
                /*guard let ball = try? await ModelEntity(named: "Ball") else {
                    print("ball not loading")
                    return
                }*/
                let ball = ModelEntity(
                    mesh: .generateSphere(radius: 0.04),
                    materials: [SimpleMaterial(color: UIColor(red: 0, green: 1, blue: 0, alpha: 1), isMetallic: false)],
                    collisionShape: .generateSphere(radius: 0.04),
                    mass: 0
                )
                ball.physicsBody?.massProperties = PhysicsMassProperties(shape: .generateSphere(radius: 0.4), mass: 1.0)
                ball.components[PhysicsBodyComponent.self]?.isAffectedByGravity = false
                ball.physicsBody?.material = PhysicsMaterialResource.generate(staticFriction: 0.5, dynamicFriction: 0.5, restitution: 0.01)
                ball.position = [0,0.5,0]
                content.add(ball)
                self.ball = ball
                
                // Scene
                guard let scene = try? await ModelEntity(named: "Scene")
                //guard let scene = try? await ModelEntity(named: "Container_30x11cm")
                 else {
                    print("scene not loading")
                    return
                }
                scene.position = [0,-0.5,0]
                content.add(scene)
                scene.components[PhysicsBodyComponent.self]?.isAffectedByGravity = false
                scene.physicsBody?.material = PhysicsMaterialResource.generate(staticFriction: 0.5, dynamicFriction: 0.5, restitution: 0.01)
                self.scene = scene
            }
            .gesture(
                SpatialTapGesture()
                    .targetedToEntity(scene)
                .onEnded { gesture in
                    print("scene tapped")
                }
            )
            .simultaneousGesture(
                DragGesture()
                    .targetedToEntity(scene)
                .onChanged { value in
                    scene.position = value.convert(value.location3D, from: .local, to: scene.parent!)
                }
            )
            .toolbar {
                ToolbarItem(placement: .bottomOrnament){
                    HStack{
                        Button("Gravity", systemImage: "arrow.down"){
                            addGravity()
                        }
                        Button("Reset", systemImage: "arrow.clockwise"){
                            reset()
                        }
                    }
                }
            }
        }
    }

    // 功能
    // 添加重力
    private func addGravity() {
        if let ball = ball as? ModelEntity {
            ball.physicsBody?.isAffectedByGravity = true
            scene.physicsBody?.isAffectedByGravity = false
            print("Gravity added to ball")
        } else {
            print("Ball is nil")
            return}
    }
    
    // 重置
    private func reset(){
        if let ball = ball as? ModelEntity{
            ball.physicsBody?.isAffectedByGravity = false
            ball.position = [0,0.5,0]
            print("Ball reset")
        }  else {
            print("Ball is nil")
            return}
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
