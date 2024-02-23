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
        WindowGroup(id: "SkyBoxControls") {
            ZStack { // Wrap TabView in a ZStack for overlaying
                TabView {
                    AssetSelectorView()
                        .environmentObject(skyBoxSettings)
                        .tabItem {
                            Label("Spaces", systemImage: "table.fill")
                        }
                    SkyBoxControlsView() // Adjustments as per previous suggestions
                        .environmentObject(skyBoxSettings)
                        .tabItem {
                            Label("Generative AI", systemImage: "wand.and.stars.inverse")
                        }
                }
                .disabled(skyBoxSettings.loading) // Optionally disable the TabView interaction

                if skyBoxSettings.loading {
                    Color.black.opacity(0.5) // Semi-transparent overlay
                        .edgesIgnoringSafeArea(.all) // Ensure it covers the whole screen
                        .contentShape(Rectangle()) // This captures taps across the whole overlay
                        .allowsHitTesting(true) // Blocks user interaction with underlying views
                        .animation(.easeInOut, value: skyBoxSettings.loading) // Smooth transition
                }
            }
        }
        .defaultSize(width: 1000, height: 500)
    }
}

class SkyboxSettings: ObservableObject {
    // Kind of a global var that contains the current skybox to show and communicate between windows.
    @Published var currentSkybox = "esteros"
    @Published var loading = false
}
