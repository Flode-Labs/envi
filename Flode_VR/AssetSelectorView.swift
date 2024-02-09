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
                    skyBoxSettings.currentSkybox = "airplane"
                }, iconName: "tree", title: "Airplane")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "anfield"
                }, iconName: "moon", title: "Anfield")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "buckingham"
                }, iconName: "sunset", title: "Buckingham Palace")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "colon"
                }, iconName: "sunset", title: "Colon Theatre")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "eiffel"
                }, iconName: "sunset", title: "Eiffel Tower")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "esteros"
                }, iconName: "sunset", title: "Esteros del Iberá")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "fitz"
                }, iconName: "sunset", title: "Mount Fitz Roy")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "iceland"
                }, iconName: "sunset", title: "Iceland")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "jefferson"
                }, iconName: "sunset", title: "Jefferson House")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "penguins"
                }, iconName: "sunset", title: "Penguins")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "perito"
                }, iconName: "sunset", title: "Perito Moreno glacier")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "salinas"
                }, iconName: "sunset", title: "Salinas Grandes")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "sunflower"
                }, iconName: "sunset", title: "Sunflowers")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "underwater"
                }, iconName: "sunset", title: "Underwater")
                
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
 
