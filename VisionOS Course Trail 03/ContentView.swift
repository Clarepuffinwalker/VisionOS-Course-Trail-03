//
//  ContentView.swift
//  VisionOS Course Trail 03
//
//  Created by ClareZhou on 2024/9/2.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

//TODO: 1. 应该将模型放入 RealityKitContent 再load，但这样不能直接load模型为ModelEntity，只能Entity，再去相应找 ModelComponent 设置，后续再设置吧，先直接文件夹 load 模型；
//TODO: 2.usda 模型组合，从 RCP 代入 xcode，是不是能很好呈现原来单独 usdc 模型的碰撞和物理设置？
//在 RealityKit 中，EventSubscription 不直接支持 store(in:) ？

struct ContentView: View {
    
    @State private var scene: ModelEntity = ModelEntity()
    @State private var ball: ModelEntity = ModelEntity()
    
    @State private var slideLong: ModelEntity = ModelEntity()
    @State private var slideShort: ModelEntity = ModelEntity()
    @State private var container: ModelEntity = ModelEntity()
    
    @State private var score: Int = 0
    @State private var subscriptions: [EventSubscription] = [] // 订阅碰撞管理

    var body: some View {
        HStack{
            VStack{
                
                // Model Sets
                RealityView { content in
                    
                    // 所有模型的碰撞和输入组件,好像在 xcode 里写，比 RCP 设置好进来好？
                    
                    // Ball
                    /*guard let ball = try? await ModelEntity(named: "Ball") else {
                     print("ball not loading")
                     return
                     }*/
                    let ball = ModelEntity(
                        mesh: .generateSphere(radius: 0.04),
                        materials: [SimpleMaterial(color: UIColor(red: 0, green: 1, blue: 0, alpha: 1), isMetallic: false)]
                    )
                    let ballPhysicsComponent = ShapeResource.generateSphere(radius: 0.04)
                    //collision
                    ball.components.set(InputTargetComponent(allowedInputTypes: [.indirect, .direct]))
                    ball.collision = CollisionComponent(shapes: [ballPhysicsComponent])
                    //physics
                    ball.physicsBody = PhysicsBodyComponent(
                        massProperties: PhysicsMassProperties(shape: ballPhysicsComponent, mass: 1000),
                        material: PhysicsMaterialResource.generate(staticFriction: 0.5, dynamicFriction: 0.5, restitution: 0.01), mode: .dynamic
                    )
                    ball.components[PhysicsBodyComponent.self]?.isAffectedByGravity = false
                    ball.position = [0.2,0.2,0]
                    content.add(ball)
                    self.ball = ball
                    
                    //Scene,容器的质量增大到不会被带下去
                    //发现一整个 scene usda 的话，在 rcp 设置过单独部件的碰撞与模拟之后，再倒入 Xcode， 可能不能很好还原每个小部件的碰撞体设置？RCP 里看都ok，一进代码是 …… 自动生成 physics包裹体了吗？逻辑有点迷
                    //先分开搭建
                    /*
                     guard let scene = try? await ModelEntity(named: "Scene")
                     else {
                     print("scene not loading")
                     return
                     }
                     scene.position = [0,-0.5,0]
                     //scene.transform.rotation = simd_quatf(angle: .pi / 4, axis: [1, 1, 0])
                     content.add(scene)
                     scene.components[PhysicsBodyComponent.self]?.isAffectedByGravity = false
                     scene.physicsBody?.material = PhysicsMaterialResource.generate(staticFriction: 0.5, dynamicFriction: 0.5, restitution: 0.01)
                     self.scene = scene
                     */
                    
                    //分开搭建场景
                    //短管
                    guard let slideShort = try? await ModelEntity(named: "Slide_Short_30cm") else {
                        print("slideShort not loading")
                        return
                    }
                    slideShort.position = [0.2,0,0]
                    // 设置collision和物理的共同组件
                    let slideShortPhysicsComponent = ShapeResource.generateBox(width: 0.1, height: 0.05, depth: 0.3)
                    // 输入和碰撞组件
                    slideShort.components.set(InputTargetComponent(allowedInputTypes: [.indirect, .direct]))
                    slideShort.collision = CollisionComponent(shapes: [slideShortPhysicsComponent])
                    //物理组件，一定要写全，包括摩擦力设置，不管后面用不用
                    slideShort.physicsBody = PhysicsBodyComponent(
                        massProperties: PhysicsMassProperties(shape: slideShortPhysicsComponent, mass: 1000),
                        material: PhysicsMaterialResource.generate(staticFriction: 0.5, dynamicFriction: 0.5, restitution: 0.01), mode: .kinematic
                    )
                    slideShort.components[PhysicsBodyComponent.self]?.isAffectedByGravity = false
                    //旋转，也可以带着碰撞、物理组件转
                    let shortRotation1 = simd_quatf(angle: .pi / -2, axis: [0, 1, 0])
                    let commonRotation = simd_quatf(angle: .pi / 6, axis: [1, 0, 0])
                    slideShort.transform.rotation =  shortRotation1 * commonRotation
                    content.add(slideShort)
                    self.slideShort = slideShort
                    
                    
                    //长管
                    guard let slideLong = try? await ModelEntity(named: "Slide_Long_50cm") else {
                        print("slideLong loading")
                        return
                    }
                    slideLong.position = [-0.2,-0.3,0]
                    //碰撞和物理
                    let slideLongPhysicsComponent = ShapeResource.generateBox(width: 0.1, height: 0.05, depth: 0.5)
                    slideLong.components.set(InputTargetComponent(allowedInputTypes: [.indirect, .direct]))
                    slideLong.collision = CollisionComponent(shapes: [slideLongPhysicsComponent])
                    //物理组件，一定要写全，包括摩擦力设置，不管后面用不用
                    slideLong.physicsBody = PhysicsBodyComponent(
                        massProperties: PhysicsMassProperties(shape: slideLongPhysicsComponent, mass: 1000),
                        material: PhysicsMaterialResource.generate(staticFriction: 0.5, dynamicFriction: 0.5, restitution: 0.01), mode: .kinematic
                    )
                    slideLong.components[PhysicsBodyComponent.self]?.isAffectedByGravity = false
                    //旋转
                    let longRotation1 = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
                    slideLong.transform.rotation = longRotation1 * commonRotation
                    content.add(slideLong)
                    self.slideLong = slideLong
                    
                    
                    //容器
                    guard let container = try? await ModelEntity(named: "Container_30x11cm") else {
                        print("container not loading")
                        return
                    }
                    container.position = [0,-0.8,0]
                    //碰撞和物理
                    let containerPhysicsComponent = ShapeResource.generateBox(width: 0.3, height: 0.1, depth: 0.3)
                    container.components.set(InputTargetComponent(allowedInputTypes: [.indirect, .direct]))
                    container.collision = CollisionComponent(shapes: [containerPhysicsComponent])
                    //物理组件，一定要写全，包括摩擦力设置，不管后面用不用
                    container.physicsBody = PhysicsBodyComponent(
                        massProperties: PhysicsMassProperties(shape: containerPhysicsComponent, mass: 1000),
                        material: PhysicsMaterialResource.generate(staticFriction: 0.5, dynamicFriction: 0.5, restitution: 0.01), mode: .static  //静态不受影响
                    )
                    container.components[PhysicsBodyComponent.self]?.isAffectedByGravity = false
                    //
                    content.add(container)
                    self.container = container
                    
                    // 监听球与容器的碰撞事件
                    let subscription = content.subscribe(to: CollisionEvents.Began.self, on: ball) { event in
                        if event.entityA == self.container || event.entityB == self.container {
                            // 停止球的运动
                            DispatchQueue.main.async {
                                self.ball.physicsBody?.mode = .kinematic
                                //self.ball.physicsBody?.linearVelocity = .zero
                                //self.ball.physicsBody?.angularVelocity = .zero
                                print("Ball stopped in container")
                                
                                // 增加分数
                                self.score += 1
                                print("Score: \(self.score)")
                            }
                        }
                    }
                    
                    // 直接存储订阅
                    subscriptions.append(subscription)
                    
                }
                .gesture(
                    SpatialTapGesture()
                        .targetedToAnyEntity()
                        .onEnded { gesture in
                            if let modelEntity = gesture.entity as? ModelEntity {
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .targetedToAnyEntity()
                        .onChanged { value in
                            if let modelEntity = value.entity as? ModelEntity {
                                modelEntity.position = value.convert(value.location3D, from: .local, to: modelEntity.parent!)
                            }
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
            } //VStack ends
            
            //score boards
            HStack{
                VStack{
                    Text("Make the Panda Happy!")
                        .font(.extraLargeTitle2)
                        .padding()
                    Text("Bamboos Collected")
                        .font(.largeTitle)
                    Text("\(self.score)")
                        .font(.extraLargeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Text("Bamboos Shoot Left:")
                }
                .frame(width:540,height:360)
                .glassBackgroundEffect()
                .padding(.leading,300)
                .padding3D(.depth,500)
                RealityView {content in
                    guard let panda = try? await ModelEntity(named: "Bamboo_shield") else {
                        print("panda loading")
                        return
                    }
                    panda.scale = [0.003,0.003,0.003]
                    panda.position = [0.0,-0.1,-0.1]
                    content.add(panda)
                }
            }
            
        } //HStack ends show score
    } //View ends

    // 功能
    // 添加重力
    private func addGravity() {
        if let ball = ball as? ModelEntity {
            ball.physicsBody?.isAffectedByGravity = true
            print("Gravity added to ball")
        } else {
            print("Ball is nil")
            return}
    }
    
    // 重置
    private func reset(){
        //others reset
        if let ball = slideShort as? ModelEntity{
            slideShort.position = [0.2,0,0]
        }
        if let ball = slideLong as? ModelEntity{
            slideLong.position = [-0.2,-0.3,0]
        }
        if let ball = container as? ModelEntity{
            container.position = [0,-0.8,0]
        }
        
        //ball reset
        if let ball = ball as? ModelEntity{
            // 停止小球的所有运动
                    ball.physicsBody = nil
            // 移除现有的物理组件
                    ball.position = [0.2, 0.2, 0]
            // 重新添加物理组件，以防 view 更新不及时，虽然小球位置移动了，但是还是按照之前的位置计算
            //物理碰撞小技巧：有时候尽管物体位置重置或者归零了，但似乎同样的碰撞体、物理位置不一定来得及及时一起归零或者回到原位，有时候，可能要清楚原来的所有物理、碰撞状态，重新设置。
                    let ballPhysicsComponent = ShapeResource.generateSphere(radius: 0.04)
                    ball.physicsBody = PhysicsBodyComponent(
                        massProperties: PhysicsMassProperties(shape: ballPhysicsComponent, mass: 1000),
                        material: PhysicsMaterialResource.generate(staticFriction: 0.5, dynamicFriction: 0.5, restitution: 0.01), mode: .dynamic
                    )
                    ball.physicsBody?.isAffectedByGravity = false
                    ball.physicsBody?.angularDamping = 0
                    ball.physicsBody?.linearDamping = 0
                    
                    print("Ball reset")
                } else {
                    print("Ball is nil")
                    return
                }
                self.score = 0 // 重置分数
                print("Score reset")
            }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
