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

struct ContentView: View {
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    @State private var isSingleOpen = false
    @State private var isMultipleOpen = false
    
    var body: some View {
        
        VStack{
            HStack{
                //SignleBallView()   // 1个球，collision detection 正常工作
                VStack{
                    Toggle("Single Ball", isOn: $isSingleOpen)
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .onChange(of:isSingleOpen){_,newValue in
                            if newValue {
                                openWindow(id:"single")
                            }
                            else {
                                dismissWindow(id:"single")
                            }
                        }
                        .toggleStyle(.button)
                    Text("单个球，正常表现")
                        .font(.title3)
                }
                .padding(50)
                
                //MultipleBallsView()  // 1组球，collision detection 和记分 有问题
                VStack{
                    Toggle("Multiple Balls", isOn: $isMultipleOpen)
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .onChange(of:isMultipleOpen){_,newValue in
                            if newValue {
                                openWindow(id:"multiple")
                            }
                            else {
                                dismissWindow(id:"multiple")
                            }
                        }
                        .toggleStyle(.button)
                    Text("多个球，碰撞正常，记分有问题")
                        .font(.title3)
                }
                .padding(50)
            }
            
            Text("规则：移动部件，接住掉落的小球即可得分")
                .font(.title3)
        }
        .frame(width:720, height:480)
        .glassBackgroundEffect()
        
    }
}


#Preview(windowStyle: .volumetric) {
    ContentView()
}
