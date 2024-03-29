import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

struct ImmersiveView: View {
    
    @Environment(\.openWindow) var openWindow
    // To have access to the object passed to the view
    @EnvironmentObject var skyBoxSettings:SkyboxSettings
    
    var body: some View {
        RealityView{ content in
            // Create a skybox
            guard let skyBoxEntity = createSkybox() else {
                return
            }
            // Add to content
            content.add(skyBoxEntity)
        } update: { content in
            // Print the latest skyBoxSettings
            //print("Latest SkyBoxSettings is: \(skyBoxSettings.currentSkybox)")
            if !skyBoxSettings.loading{
                // Update current skybox
                //Check if the current skybox is a URL or a prebuilt skybox
                if skyBoxSettings.currentSkybox.contains("http") {
                    updateSkyboxURL(with: skyBoxSettings.currentSkybox, content: content)
                } else {
                    updateSkybox(with: skyBoxSettings.currentSkybox, content: content)
                }
            }else{
                updateVideoSkybox(content: content)
                
            }
        }
        .onAppear(perform: {
            // Present the skybox control window
            openWindow(id: "SkyBoxControls")
            
        })
    }
    
    private func createSkybox () -> Entity? {
        // Mesh (large sphere)
        let skyBoxMesh = MeshResource.generateSphere(radius: 1000)
        // Material (skybox image)
        var skyBoxMaterial = UnlitMaterial()
        let remoteURL = URL(string: "https://replicate.delivery/pbxt/OtqGeEiTTfk7CU7jj6ogbwRmVs7dxKbaFtax5FmyqNtjKXUSA/6-final.png")!
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let data = try! Data(contentsOf: remoteURL)
        try! data.write(to: fileURL)
        
        guard let skyBoxTexture = try? TextureResource.load(contentsOf: fileURL) else {return nil}
        skyBoxMaterial.color = .init(texture: .init(skyBoxTexture))
        // Entity
        let skyBoxEntity = Entity()
        skyBoxEntity.components.set(ModelComponent(
            mesh: skyBoxMesh,
            materials: [skyBoxMaterial]
        )
        )
        // Associate a name with the skybox
        skyBoxEntity.name = "SkyBox"
        
        // Map image to inner surface or sphere
        skyBoxEntity.scale = .init(x:-1, y:1, z:1)

        //The sky box is rotated 90 degrees to the right and I want to fix it
        skyBoxEntity.orientation = simd_quatf(angle: .pi/2, axis: [0, 1, 0])
        
        return skyBoxEntity
    }
    // Updates the current skybox
    private func updateSkybox (with newSkyBoxName:String, content:RealityViewContent){
        // Get skybox entity from content
        // Loop trought the entities and retrieve the one that has SkyBox name
        let skyBoxEntity = content.entities.first{ entity in
            entity.name == "SkyBox"
        }
        
        
        
        // Update its material (to latest skybox)
        guard let updatedSkyBoxTexture = try? TextureResource.load(named: newSkyBoxName) else {
            return
        }
        
        var updatedskyBoxMaterial = UnlitMaterial()
        updatedskyBoxMaterial.color = .init(texture: .init(updatedSkyBoxTexture))
        
        skyBoxEntity?.components.set(
            ModelComponent(
                mesh: MeshResource.generateSphere(radius: 1000),
                materials: [updatedskyBoxMaterial]
            )
        )
        
    }
    
    // Updates the current skybox
    private func updateVideoSkybox (content:RealityViewContent){
        let skyBoxEntity = content.entities.first{ entity in
                    entity.name == "SkyBox"
                }
                
                // Update its material (to latest skybox)
        guard let videoMaterial = createVideoMaterial() else {
            return
        }
            
                skyBoxEntity?.components.set(
                    ModelComponent(
                    mesh: MeshResource.generateSphere(radius: 1000),
                            materials: [videoMaterial]
                        )
                    )
    }
    
    private func updateSkyboxURL (with newSkyBoxName:String, content:RealityViewContent){
        // Get skybox entity from content
        // Loop trought the entities and retrieve the one that has SkyBox name
        let skyBoxEntity = content.entities.first{ entity in
            entity.name == "SkyBox"
        }
        
        let remoteURL = URL(string:newSkyBoxName )!
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let data = try! Data(contentsOf: remoteURL)
        try! data.write(to: fileURL)
        
        
        // Update its material (to latest skybox)
        guard let updatedSkyBoxTexture = try? TextureResource.load(contentsOf: fileURL)
        else {
            return
        }
        
        var updatedskyBoxMaterial = UnlitMaterial()
        updatedskyBoxMaterial.color = .init(texture: .init(updatedSkyBoxTexture))
        
        skyBoxEntity?.components.set(
            ModelComponent(
                mesh: MeshResource.generateSphere(radius: 1000),
                materials: [updatedskyBoxMaterial]
            )
        )
        
    }
}

private func createVideoMaterial()-> VideoMaterial? {
    // Load the video
    guard let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
        return nil
    }
    let avPlayer = AVPlayer(url: videoURL)
    // Create the video material
    let videoMaterial = VideoMaterial(avPlayer: avPlayer)
    avPlayer.play()
    
    return videoMaterial
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
