
import SwiftUI

@main
struct Flode_VRApp: App {
    @ObservedObject var skyBoxSettings = SkyboxSettings()
    
    var body: some Scene {
        // VR
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environmentObject(skyBoxSettings)
        }.immersionStyle(selection: .constant(.full), in: .full)
        
        // Window
        WindowGroup(id: "SkyBoxControls"){
            TabView {
                AssetSelectorView()
                    .environmentObject(skyBoxSettings)
                    .tabItem {
                        Label("Spaces", systemImage: "table.fill")
                    }
                SkyBoxControlsView()
                    .environmentObject(skyBoxSettings)
                    .tabItem {
                        Label("Generative AI", systemImage: "wand.and.stars.inverse")
                    }
                SettingsView()
                    .environmentObject(skyBoxSettings)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                SavedEnvironmentsView()
                    .environmentObject(skyBoxSettings)
                    .tabItem {
                        Label("Saved", systemImage: "folder.fill")
                    }
            }
        }
        .defaultSize(width: 1000, height: 500)
    }
}

class SkyboxSettings: ObservableObject {
    @Published var currentSkybox = "esteros"
    @Published var loading = false
    @Published var openAIAPIKey: String = ""
    @Published var replicateAPIKey: String = ""
    @Published var userPreferences = UserPreferences()
    @Published var savedEnvironments: [String] = []
}

