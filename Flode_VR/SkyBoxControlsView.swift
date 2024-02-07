//
//  SkyBoxControlsView.swift
//  Flode_VR
//
//  Created by Tadeo Donegana Braunschweig on 06/02/2024.
//

import SwiftUI

struct SkyBoxControlsView: View {
    
    // To have access to the object passed to the view
    @EnvironmentObject var skyBoxSettings:SkyboxSettings
    
    var body: some View {
        HStack {
            SkyBoxButton(onClick: {
                // Change skybox
                skyBoxSettings.currentSkybox = "anime"
            }, iconName: "tree")
            
            SkyBoxButton(onClick: {
                skyBoxSettings.currentSkybox = "beach"
            }, iconName: "moon")
            
            SkyBoxButton(onClick: {
                skyBoxSettings.currentSkybox = "stadium"
            }, iconName: "sunset")
        }
    }
}

#Preview {
    SkyBoxControlsView()
}

// Button view
struct SkyBoxButton: View {
    var onClick: () -> Void
    var iconName:String
    
    var body: some View {
        Button(action: {
            // Change skybox
            onClick()
        }, label: {
            Image(systemName: iconName)
        })
    }
}
