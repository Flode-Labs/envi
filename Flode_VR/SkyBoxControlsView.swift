//
//  SkyBoxControlsView.swift
//  Flode_VR
//
//  Created by Tadeo Donegana Braunschweig on 06/02/2024.
//
import SwiftUI
import Replicate
import Foundation

struct SkyBoxControlsView: View {
    @EnvironmentObject var skyBoxSettings: SkyboxSettings
    @AppStorage("APIKey") private var apiKey: String = ""
    @State private var inputApiKey: String = ""
    @State private var prompt: String = ""
    @State private var isToolbarVisible: Bool = true
    @State private var isApiKeySavedAlertVisible: Bool = false // For API key saved notification
    @State private var isSubmitting: Bool = false // To manage the submission state

    private var replicate: Replicate.Client {
        Replicate.Client(token: apiKey.isEmpty ? "API" : apiKey)
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    // Adjusting structure for short titles and detailed prompts
    let templatePrompts: [String: (title: String, detailedPrompt: String)] = [
        "sunrise.fill": ("Sunrise", "Sunrise over mountains"),
        "sunset.fill": ("Sunset", "Beautiful sunset by the beach"),
        "sparkles": ("Stars", "Starry night sky"),
        "tree.fill": ("Forest", "Misty forest at dawn"),
        "building.2.fill": ("City", "Futuristic cityscape at night"),
        "mountain.2.fill": ("Mountains", "Snowy mountains under clear blue sky"),
        "hurricane": ("Anime", "Tokio city street anime style"),
        "sparkle": ("Galaxy", "Galaxy"),
        "book.fill": ("Fantasy", "Fantasy forest of elf"),
        "tornado.circle.fill": ("Desert", "Desert"),
    ]
    
    var body: some View {
        VStack {
            Text("Generate a new environment using AI").font(.largeTitle)

            HStack {
                SecureField("API Key", text: $inputApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Save") {
                    apiKey = inputApiKey
                    isApiKeySavedAlertVisible = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isApiKeySavedAlertVisible = false
                    }
                }
                .padding()
                .alert(isPresented: $isApiKeySavedAlertVisible) {
                    Alert(title: Text("API Key Saved"), message: Text("Your API key has been successfully saved."), dismissButton: .default(Text("OK")))
                }

                Button(action: {
                    openURL(URL(string: "https://replicate.com/account/api-tokens")!)
                }) {
                    Image(systemName: "arrow.up.right.square")
                }
            }
            .padding(.bottom, 20)
            .disabled(isSubmitting) // Disable input while submitting

            Text("Examples").font(.largeTitle)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(Array(templatePrompts.keys), id: \.self) { key in
                    let item = templatePrompts[key]!
                    Button(action: {
                        self.prompt = item.detailedPrompt
                    }) {
                        VStack {
                            Image(systemName: key)
                                .font(.largeTitle)
                            Text(item.title)
                                .font(.caption)
                        }
                    }
                    .disabled(isSubmitting) // Disable example buttons while submitting
                }
            }
            .padding(.horizontal, 50)
            .toolbar {
                if isToolbarVisible {
                    ToolbarItem(placement: .bottomOrnament) {
                        HStack {
                            TextField("Enter the prompt for the environment", text: $prompt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isSubmitting) // Disable input while submitting

                            Button(action: {
                                Task {
                                    try await callApiAndUpdateSkybox(with: prompt)
                                }
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(isSubmitting || prompt.isEmpty || apiKey.isEmpty ? Color.gray : Color.blue)
                                    .clipShape(Circle())
                            }
                            .disabled(isSubmitting || prompt.isEmpty || apiKey.isEmpty) // Disable submit button conditionally
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .onAppear {
                isToolbarVisible = true
            }
            .onDisappear {
                isToolbarVisible = false
            }
        }
    }
    
    func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }

    
    // Calls the API and returns the generated image
    func callApiAndUpdateSkybox(with input: String) async {
        self.isSubmitting = true
        defer { self.isSubmitting = false }

        do {
            self.skyBoxSettings.loading = true
            let model = try await replicate.getModel("lucataco/sdxl-panoramic")
            if let latestVersion = model.latestVersion {
                let prediction = try await replicate.createPrediction(version: latestVersion.id,
                                                                      input: ["prompt": "HDRI View, \(input)"],
                                                                      wait: true)
                if let urlString = prediction.output {
                    self.skyBoxSettings.currentSkybox = urlString.stringValue ?? ""
                }
            }
        } catch {
            print("Error during prediction: \(error)")
        }
        self.skyBoxSettings.loading = false
    }
    
}

// Example Preview Provider
struct SkyBoxControlsView_Previews: PreviewProvider {
    static var previews: some View {
        SkyBoxControlsView().environmentObject(SkyboxSettings())
    }
}
