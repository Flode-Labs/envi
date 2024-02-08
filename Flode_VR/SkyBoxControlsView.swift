//
//  SkyBoxControlsView.swift
//  Flode_VR
//
//  Created by Tadeo Donegana Braunschweig on 06/02/2024.
//
import SwiftUI
import Replicate

struct SkyBoxControlsView: View {
    @EnvironmentObject var skyBoxSettings: SkyboxSettings
    @State private var inputUrl: String = ""

    var body: some View {
        VStack {
            HStack {
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "anime"
                }, iconName: "tree")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "beach"
                }, iconName: "moon")
                
                SkyBoxButton(onClick: {
                    skyBoxSettings.currentSkybox = "stadium"
                }, iconName: "sunset")
            }
            // New UI elements for URL input and send button
            HStack {
                TextField("Enter SkyBox URL", text: $inputUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    // Call API and update SkyBoxSettings with the response
                    callApiAndUpdateSkybox(with: inputUrl)
                }) {
                    Image(systemName: "wand.and.stars.inverse") // Adjust the icon to match your UI
                        .padding()
                }
            }
        }
    }
    
    struct PredictionInput: Codable {
        var version: String
        var input: Prompt
    }

    struct Prompt: Codable {
        var prompt: String
    }
    
    // Llama a la API y devuelve la URL de la imagen generada
    func callApiAndUpdateSkybox(with url: String) {
        self.skyBoxSettings.currentSkybox = "https://replicate.delivery/pbxt/OtqGeEiTTfk7CU7jj6ogbwRmVs7dxKbaFtax5FmyqNtjKXUSA/6-final.png"
        
        
        guard let url = URL(string: "https://api.replicate.com/v1/predictions") else { return }
        
        let predictionInput = PredictionInput(version: "76acc4075d0633dcb3823c1fed0419de21d42001b65c816c7b5b9beff30ec8cd", input: Prompt(prompt: "hdri view, aurora night in a mountain"))
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Token $REPLICATE_API_TOKEN", forHTTPHeaderField: "Authorization") // Reemplaza $REPLICATE_API_TOKEN con tu token real
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(predictionInput)
            request.httpBody = jsonData
        } catch {
            print("Error encoding input: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print(response as? HTTPURLResponse as Any)
                print("Invalid response or status code")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Intenta imprimir la respuesta como un String
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            } else {
                print("Error converting data to String")
            }
        }.resume()
    }
    
}

struct SkyBoxButton: View {
    var onClick: () -> Void
    var iconName: String
    
    var body: some View {
        Button(action: onClick, label: {
            Image(systemName: iconName)
        })
    }
}


// Example Preview Provider
struct SkyBoxControlsView_Previews: PreviewProvider {
    static var previews: some View {
        SkyBoxControlsView().environmentObject(SkyboxSettings())
    }
}
