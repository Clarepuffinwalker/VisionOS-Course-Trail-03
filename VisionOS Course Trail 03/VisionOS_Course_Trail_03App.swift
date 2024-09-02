//
//  VisionOS_Course_Trail_03App.swift
//  VisionOS Course Trail 03
//
//  Created by 周铁 on 2024/9/2.
//

import SwiftUI

@main
struct VisionOS_Course_Trail_03App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
