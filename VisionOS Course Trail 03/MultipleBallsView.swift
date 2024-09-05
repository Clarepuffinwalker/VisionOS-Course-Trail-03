//
//  MultipleBallsView.swift
//  VisionOS Course Trail 03
//
//  Created by ClareZhou on 2024/9/3.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct MultipleBallsView: View {

    //TODO: 1. 应该将模型放入 RealityKitContent 再load，但这样不能直接load模型为ModelEntity，只能Entity，再去相应找 ModelComponent 设置，后续再设置吧，先直接文件夹 load 模型；
    //TODO: 2.usda 模型组合，从 RCP 代入 xcode，是不是能很好呈现原来单独 usdc 模型的碰撞和物理设置？
    //在 RealityKit 中，EventSubscription 不直接支持 store(in:) ？
        
    @State private var scene: ModelEntity = ModelEntity()
    @State private var ball: ModelEntity = ModelEntity()
    
    @State private var slideLong: ModelEntity = ModelEntity()
    @State private var slideShort: ModelEntity = ModelEntity()
    @State private var container: ModelEntity = ModelEntity()
    
    @State private var balls: ModelEntity = ModelEntity() // 存储所有小球的容器
    @State private var timer: Timer?
    @State private var ballDrop: Int = 0
    private let radius: Float = 0.04 // 小球半径
    private let ballTotal: Int = 20 // 生成小球的总数
    
    @State private var score: Int = 0
    @State private var subscriptions: [EventSubscription] = [] // 订阅碰撞管理

        var body: some View {
            HStack{
                VStack{
                    
                    // Model Sets
                    RealityView { content in
                        // 初始化小球
                        initBalls()
                        
                        // 将所有小球添加到场景中
                        for ball in balls.children {
                            content.add(ball)
                        }
                        //content.add(ball) // 将小球添加到场景中
                        content.add(balls)
                        
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
                        
                        // 添加所有小球到碰撞监听中
                        for case let ball as ModelEntity in balls.children {
                            let subscription = content.subscribe(to: CollisionEvents.Began.self, on: ball) { event in
                                // 打印详细的碰撞信息，方便调试
                                print("Collision detected between: \(event.entityA) and \(event.entityB)")

                                // 判断是否是和容器发生了碰撞
                                if (event.entityA == self.container && event.entityB == ball) ||
                                   (event.entityA == ball && event.entityB == self.container) {
                                    DispatchQueue.main.async {
                                        // 停止球的运动
                                        ball.physicsBody?.mode = .kinematic

                                        // 增加分数
                                        self.score += 1
                                        print("Score: \(self.score)")
                                    }
                                }
                            }
                            // 将订阅存储
                            subscriptions.append(subscription)
                        }
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
                                    startDroppingBalls()
                                    //dropNextBall()
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
                        Text("Bamboos Shoot Left:" + "\(ballTotal - ballDrop) ")
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
    // 小球初始化
    private func initBalls() {
        // 如果 balls 容器为空，才初始化小球
        if balls.children.isEmpty {
            for _ in 0..<ballTotal {
                let ball = ModelEntity(
                    mesh: .generateSphere(radius: radius),
                    materials: [SimpleMaterial(color: UIColor(red: 0, green: 1, blue: 0, alpha: 1), isMetallic: false)]
                )
                ball.physicsBody = PhysicsBodyComponent(
                    massProperties: PhysicsMassProperties(shape: .generateSphere(radius: radius), mass: 1),
                    material: PhysicsMaterialResource.generate(staticFriction: 0.5, dynamicFriction: 0.5, restitution: 0.01),
                    mode: .dynamic
                )
                ball.collision = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: radius)])
                ball.physicsBody?.isAffectedByGravity = false // 初始不受重力影响
                
                balls.addChild(ball) // 将小球添加到 balls 容器中
            }
        }
    }
    
    private func startDroppingBalls() {
        ballDrop = 0 // 重置计数
        timer?.invalidate() // 停止之前的计时器
        // 创建一个新的计时器，每秒生成一个小球
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.dropNextBall()
        }
    }

    private func dropNextBall() {
        guard ballDrop < ballTotal else {
            timer?.invalidate() // 停止计时器
            return
        }
        let ball = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [SimpleMaterial(color: UIColor(red: 0, green: 1, blue: 0, alpha: 1), isMetallic: false)]
        )
        
        let ballPhysicsComponent = ShapeResource.generateSphere(radius: radius)
        ball.physicsBody = PhysicsBodyComponent(
            massProperties: PhysicsMassProperties(shape: ballPhysicsComponent, mass: 1),
            material: PhysicsMaterialResource.generate(staticFriction: 0.5, dynamicFriction: 0.5, restitution: 0.01),
            mode: .dynamic
        )
        // 小球位置
        ball.position = [0.2, 0.2, 0] // 相同位置
        //ball.position = [Float.random(in: -0.5...0.5), 0.5, 0] // 随机位置
        ball.collision = CollisionComponent(shapes: [ballPhysicsComponent])
        ball.physicsBody?.isAffectedByGravity = true
        // 将小球添加到场景中的 balls 容器中
        balls.addChild(ball)
        ballDrop += 1
        //print("Ball dropped: \(ballDrop), position: \(ball.position)")
    }
    
    
        
        // 重置
        private func reset(){
            //others reset
            if let slideShort = slideShort as? ModelEntity{
                slideShort.position = [0.2,0,0]
            }
            if let slideLong = slideLong as? ModelEntity{
                slideLong.position = [-0.2,-0.3,0]
            }
            if let container = container as? ModelEntity{
                container.position = [0,-0.8,0]
            }
            
            //ball reset
            if let ball = ball as? ModelEntity{
                timer?.invalidate()
                    ballDrop = 0

                    // 清除所有小球
                    balls.children.forEach { $0.removeFromParent() }
                
                // 停止小球的所有运动,重设位置
                        ball.physicsBody = nil
                        ball.position = [0.2, 0.2, 0]
               //ball.position = [Float.random(in: -0.5...0.5), 0.5, 0]
    
                // 重新添加物理组件，以防 view 更新不及时，虽然小球位置移动了，但是还是按照之前的位置计算
                //物理碰撞小技巧：有时候尽管物体位置重置或者归零了，但似乎同样的碰撞体、物理位置不一定来得及及时一起归零或者回到原位，有时候，可能要清楚原来的所有物理、碰撞状态，重新设置。
                        let ballPhysicsComponent = ShapeResource.generateSphere(radius: radius)
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

#Preview {
    MultipleBallsView()
}
