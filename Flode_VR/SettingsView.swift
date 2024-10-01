//
//  SettingsView.swift
//  Flode_VR
//
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var skyBoxSettings: SkyboxSettings
    @State private var showOpenAIKey: Bool = false
    @State private var showReplicateKey: Bool = false

    let styles = [
        (name: "Animated", imageName: "animated"),
        (name: "Cartoon", imageName: "cartoon"),
        (name: "Realistic", imageName: "realistic"),
        (name: "Abstract", imageName: "abstract")
    ]

    let avoidOptions = [
        (name: "Scary Things", imageName: "scary"),
        (name: "Monsters", imageName: "monster"),
        (name: "Persons", imageName: "persons"),
        (name: "Violence", imageName: "violence")
    ]

    var body: some View {
        VStack {
            Text("Settings").font(.largeTitle)
            Form {
                Section(header: Text("API Keys")) {
                    HStack {
                        if showOpenAIKey {
                            TextField("OpenAI API Key", text: $skyBoxSettings.openAIAPIKey)
                        } else {
                            SecureField("OpenAI API Key", text: $skyBoxSettings.openAIAPIKey)
                        }
                        Button(action: {
                            showOpenAIKey.toggle()
                        }) {
                            Image(systemName: showOpenAIKey ? "eye.slash" : "eye")
                        }
                    }
                    HStack {
                        if showReplicateKey {
                            TextField("Replicate API Key", text: $skyBoxSettings.replicateAPIKey)
                        } else {
                            SecureField("Replicate API Key", text: $skyBoxSettings.replicateAPIKey)
                        }
                        Button(action: {
                            showReplicateKey.toggle()
                        }) {
                            Image(systemName: showReplicateKey ? "eye.slash" : "eye")
                        }
                    }
                }
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $skyBoxSettings.userPreferences.improvePrompt) {
                        Text("Improve Prompt")
                    }
                    .disabled(skyBoxSettings.openAIAPIKey.isEmpty) // Disable if OpenAI API key is not provided

                    Text("Select a style you prefer:")
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(styles, id: \.name) { style in
                                VStack {
                                    Image(style.imageName)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .border(skyBoxSettings.userPreferences.style == style.name ? Color.blue : Color.clear, width: 2)
                                        .onTapGesture {
                                            skyBoxSettings.userPreferences.style = style.name
                                        }
                                    Text(style.name)
                                }
                            }
                        }
                    }
                    Text("Select things you want to avoid:")
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(avoidOptions, id: \.name) { option in
                                VStack {
                                    Image(option.imageName)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .border(skyBoxSettings.userPreferences.avoid.contains(option.name) ? Color.red : Color.clear, width: 2)
                                        .onTapGesture {
                                            if skyBoxSettings.userPreferences.avoid.contains(option.name) {
                                                skyBoxSettings.userPreferences.avoid.removeAll { $0 == option.name }
                                            } else {
                                                skyBoxSettings.userPreferences.avoid.append(option.name)
                                            }
                                        }
                                    Text(option.name)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// Preview Provider
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SkyboxSettings())
    }
}
