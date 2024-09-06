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
        //.windowStyle(.volumetric)
        .windowStyle(.plain)
        .defaultSize(width: 2.0, height: 2.0, depth: 1.0, in: .meters)
        .windowResizability(.contentSize)
        
        
        WindowGroup(id:"single") {
            SingleBallView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 2.0, depth: 1.0, in: .meters)
        .windowResizability(.contentSize)
        
        
        WindowGroup(id:"multiple") {
            MultipleBallsView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 2.0, depth: 1.0, in: .meters)
        .windowResizability(.contentSize)
        
    }
}
