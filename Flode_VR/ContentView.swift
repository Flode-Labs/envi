//
//  ContentView.swift
//  Flode_VR
//
//  Created by Tadeo Donegana Braunschweig on 06/02/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        Text("Hello World")
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
