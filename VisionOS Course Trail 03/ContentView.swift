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
    
    @State private var balls: ModelEntity = ModelEntity() // 存储所有小球的容器
    @State private var timer: Timer?
    @State private var ballDrop: Int = 0
    private let radius: Float = 0.04 // 小球半径
    private let ballTotal: Int = 20 // 生成小球的总数
    
    @State private var score: Int = 0
    @State private var subscriptions: [EventSubscription] = [] // 订阅碰撞管理
    
    var body: some View {
        HStack{
            //SignleBallView()   // 1个球，collision detection 正常工作
            MultipleBallsView()  // 1组球，collision detection 和记分 有问题
        }
    }
}


#Preview(windowStyle: .volumetric) {
    ContentView()
}
