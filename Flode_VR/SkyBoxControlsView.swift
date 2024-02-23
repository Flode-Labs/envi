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
    @State private var isApiKeySavedAlertVisible: Bool = false // Alert state for API key saved
    @State private var isSubmitting: Bool = false // State to manage submission status

    private var replicate: Replicate.Client {
        Replicate.Client(token: apiKey.isEmpty ? "API" : apiKey)
    }
    
    var body: some View {
        VStack {
            Text("Generate a new environment using AI").font(.largeTitle)

            HStack {
                SecureField("API Key", text: $inputApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Save") {
                    apiKey = inputApiKey
                    isApiKeySavedAlertVisible = true // Show saved notification
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        // Hide the alert after 2 seconds
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
            .disabled(isSubmitting) // Disable examples while submitting

            // Other UI elements...

            TextField("Enter the prompt for the environment", text: $prompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(isSubmitting) // Disable input while submitting

            Button(action: {
                Task {
                    await callApiAndUpdateSkybox(with: prompt)
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(isSubmitting || prompt.isEmpty || apiKey.isEmpty ? Color.gray : Color.blue) // Conditional color
                    .clipShape(Circle())
            }
            .disabled(isSubmitting || prompt.isEmpty || apiKey.isEmpty) // Disable button conditionally
        }
    }

    // Calls the API and returns the generated image
    func callApiAndUpdateSkybox(with input: String) async {
        self.isSubmitting = true // Begin submission
        defer { self.isSubmitting = false } // Ensure isSubmitting is reset
        
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

struct SkyBoxControlsView_Previews: PreviewProvider {
    static var previews: some View {
        SkyBoxControlsView().environmentObject(SkyboxSettings())
    }
}
