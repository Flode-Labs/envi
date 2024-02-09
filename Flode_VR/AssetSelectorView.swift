//
//  SkyBoxControlsView.swift
//  Flode_VR
//
//  Created by Tadeo Donegana Braunschweig on 06/02/2024.
//

import SwiftUI

struct AssetSelectorView: View {
    
    // To have access to the object passed to the view
    @EnvironmentObject var skyBoxSettings:SkyboxSettings
    
    var body: some View {
        VStack{
            Text("Predefined Examples").font(.largeTitle)
            HStack {
                SkyBoxButton(onClick: {
                    // Change skybox
                    skyBoxSettings.currentSkybox = "anime"
                }, iconName: "tree", title: "Anime")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "beach"
                }, iconName: "moon", title: "Anime")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "mars"
                }, iconName: "sunset", title: "Anime")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "mars"
                }, iconName: "sunset", title: "Anime")
            }
            .padding(.top, 20)
        }

    }
}

#Preview {
    SkyBoxControlsView()
}

struct SkyBoxButton: View {
    var onClick: () -> Void
    var iconName: String
    var title: String
    
    var body: some View {
        Button(action: onClick, label: {
            Image(systemName: iconName)
                .font(.largeTitle)
            Text(title) // Using short title
                .font(.caption)
        })
    }
}
 
