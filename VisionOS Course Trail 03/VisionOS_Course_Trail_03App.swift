//
//  VisionOS_Course_Trail_03App.swift
//  VisionOS Course Trail 03
//
//  Created by ClareZhou on 2024/9/2.
//

import SwiftUI

@main
struct VisionOS_Course_Trail_03App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 2.0, depth: 1.0, in: .meters)
        .windowResizability(.contentSize)
    }
}
