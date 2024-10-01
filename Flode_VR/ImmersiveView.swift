

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

struct ImmersiveView: View {
    
    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var skyBoxSettings: SkyboxSettings
    
    var body: some View {
        RealityView { content in
            guard let skyBoxEntity = createSkybox() else {
                return
            }
            content.add(skyBoxEntity)
        } update: { content in
            if !skyBoxSettings.loading {
                if skyBoxSettings.currentSkybox.contains("http") || skyBoxSettings.currentSkybox.contains("file://") {
                    updateSkyboxURL(with: skyBoxSettings.currentSkybox, content: content)
                } else {
                    updateSkybox(with: skyBoxSettings.currentSkybox, content: content)
                }
            } else {
                updateVideoSkybox(content: content)
            }
        }
        .onAppear {
            openWindow(id: "SkyBoxControls")
        }
    }
    
    private func createSkybox() -> Entity? {
        let skyBoxMesh = MeshResource.generateSphere(radius: 1000)
        var skyBoxMaterial = UnlitMaterial()
        guard let skyBoxTexture = try? TextureResource.load(named: skyBoxSettings.currentSkybox) else { return nil }
        skyBoxMaterial.color = .init(texture: .init(skyBoxTexture))
        let skyBoxEntity = Entity()
        skyBoxEntity.components.set(ModelComponent(
            mesh: skyBoxMesh,
            materials: [skyBoxMaterial]
        ))
        skyBoxEntity.name = "SkyBox"
        skyBoxEntity.scale = .init(x: -1, y: 1, z: 1)
        skyBoxEntity.orientation = simd_quatf(angle: .pi/2, axis: [0, 1, 0])
        return skyBoxEntity
    }
    
    private func updateSkybox(with newSkyBoxName: String, content: RealityViewContent) {
        let skyBoxEntity = content.entities.first { entity in
            entity.name == "SkyBox"
        }
        
        guard let updatedSkyBoxTexture = try? TextureResource.load(named: newSkyBoxName) else {
            return
        }
        
        var updatedSkyBoxMaterial = UnlitMaterial()
        updatedSkyBoxMaterial.color = .init(texture: .init(updatedSkyBoxTexture))
        
        skyBoxEntity?.components.set(
            ModelComponent(
                mesh: MeshResource.generateSphere(radius: 1000),
                materials: [updatedSkyBoxMaterial]
            )
        )
    }
    
    private func updateSkyboxURL(with newSkyBoxName: String, content: RealityViewContent) {
        let skyBoxEntity = content.entities.first { entity in
            entity.name == "SkyBox"
        }
        
        var skyBoxTexture: TextureResource?
        
        if newSkyBoxName.hasPrefix("http") {
            let remoteURL = URL(string: newSkyBoxName)!
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            let data = try! Data(contentsOf: remoteURL)
            try! data.write(to: fileURL)
            skyBoxTexture = try? TextureResource.load(contentsOf: fileURL)
        } else if newSkyBoxName.hasPrefix("file://") {
            let fileURL = URL(string: newSkyBoxName)!
            skyBoxTexture = try? TextureResource.load(contentsOf: fileURL)
        } else {
            let fileURL = URL(fileURLWithPath: newSkyBoxName)
            skyBoxTexture = try? TextureResource.load(contentsOf: fileURL)
        }
        
        guard let updatedSkyBoxTexture = skyBoxTexture else {
            return
        }
        
        var updatedSkyBoxMaterial = UnlitMaterial()
        updatedSkyBoxMaterial.color = .init(texture: .init(updatedSkyBoxTexture))
        
        skyBoxEntity?.components.set(
            ModelComponent(
                mesh: MeshResource.generateSphere(radius: 1000),
                materials: [updatedSkyBoxMaterial]
            )
        )
    }
    
    private func updateVideoSkybox(content: RealityViewContent) {
        let skyBoxEntity = content.entities.first { entity in
            entity.name == "SkyBox"
        }
        
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
    
    private func createVideoMaterial() -> VideoMaterial? {
        guard let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
            return nil
        }
        let avPlayer = AVPlayer(url: videoURL)
        let videoMaterial = VideoMaterial(avPlayer: avPlayer)
        avPlayer.play()
        return videoMaterial
    }
}

// Preview Provider
struct ImmersiveView_Previews: PreviewProvider {
    static var previews: some View {
        ImmersiveView()
            .environmentObject(SkyboxSettings())
            .previewLayout(.sizeThatFits)
    }
}
