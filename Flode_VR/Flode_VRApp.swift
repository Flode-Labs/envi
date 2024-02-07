//
//  Flode_VRApp.swift
//  Flode_VR
//
//  Created by Tadeo Donegana Braunschweig on 06/02/2024.
//

import SwiftUI

@main
struct Flode_VRApp: App {
    // To listen and have the changes of currentSkybox
    @ObservedObject var skyBoxSettings = SkyboxSettings()
    
    var body: some Scene {
        // VR
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                // Pass the env object to the view
                .environmentObject(skyBoxSettings)
        }.immersionStyle(selection: .constant(.full), in: .full)
        
        // Window
        WindowGroup(id: "SkyBoxControls"){
            SkyBoxControlsView()
                .environmentObject(skyBoxSettings)
        }
        .defaultSize(width: 30, height: 30)
    }
}

class SkyboxSettings: ObservableObject {
    // Kind of a global var that contains the current skybox to show and communicate between windows.
    @Published var currentSkybox = ""
}
