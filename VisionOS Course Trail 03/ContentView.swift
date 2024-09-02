//
//  ContentView.swift
//  VisionOS Course Trail 03
//
//  Created by ClareZhou on 2024/9/2.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
