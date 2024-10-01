
import SwiftUI
import Replicate
import Foundation
import AVFoundation

struct SkyBoxControlsView: View {
    @EnvironmentObject var skyBoxSettings: SkyboxSettings
    @State private var prompt: String = ""
    @State private var isToolbarVisible: Bool = true
    @State private var isSubmitting: Bool = false

    // Audio players
    private var promptMissingPlayer: AVAudioPlayer?
    private var apiKeyMissingPlayer: AVAudioPlayer?
    private var welcomePlayer: AVAudioPlayer?
    private var generatingPlayer: AVAudioPlayer?
    private var generationFailedPlayer: AVAudioPlayer?

    // Replicate client
    private var replicate: Replicate.Client {
        Replicate.Client(token: skyBoxSettings.replicateAPIKey.isEmpty ? "API" : skyBoxSettings.replicateAPIKey)
    }

    init() {
        // Initialize the audio players
        promptMissingPlayer = loadAudioPlayer(fileName: "promptMissing")
        apiKeyMissingPlayer = loadAudioPlayer(fileName: "apikeyMissing")
        welcomePlayer = loadAudioPlayer(fileName: "welcome")
        generatingPlayer = loadAudioPlayer(fileName: "environmentCreating")
        generationFailedPlayer = loadAudioPlayer(fileName: "environmentFailed")
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
        "hurricane": ("Anime", "Tokyo city street anime style"),
        "sparkle": ("Galaxy", "Galaxy"),
        "book.fill": ("Fantasy", "Fantasy forest of elf"),
        "tornado.circle.fill": ("Desert", "Desert"),
    ]

    var body: some View {
        VStack {
            Text("Generate a new environment using AI").font(.largeTitle)

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
                    .disabled(isSubmitting)
                }
            }
            .padding(.horizontal, 50)
            .toolbar {
                if isToolbarVisible {
                    ToolbarItem(placement: .bottomOrnament) {
                        HStack {
                            TextField("Enter the prompt for the environment", text: $prompt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isSubmitting)

                            Button(action: {
                                if prompt.isEmpty {
                                    playAudio(audioPlayer: promptMissingPlayer)
                                    return
                                } else if skyBoxSettings.replicateAPIKey.isEmpty {
                                    playAudio(audioPlayer: apiKeyMissingPlayer)
                                    return
                                }

                                Task {
                                    await callApiAndUpdateSkybox(with: prompt)
                                }
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .onAppear {
                isToolbarVisible = true
                if skyBoxSettings.replicateAPIKey.isEmpty {
                    playAudio(audioPlayer: welcomePlayer)
                }
            }
            .onDisappear {
                isToolbarVisible = false
            }
        }
    }

    func loadAudioPlayer(fileName: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return nil }
        return try? AVAudioPlayer(contentsOf: url)
    }

    func playAudio(audioPlayer: AVAudioPlayer?) {
        [promptMissingPlayer, apiKeyMissingPlayer, welcomePlayer, generatingPlayer, generationFailedPlayer].forEach { player in
            if player !== audioPlayer {
                player?.stop()
            }
        }
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }

    // Calls the API and returns the generated image
    func callApiAndUpdateSkybox(with input: String) async {
        playAudio(audioPlayer: generatingPlayer)

        self.isSubmitting = true
        defer { self.isSubmitting = false }

        do {
            self.skyBoxSettings.loading = true

            var promptToUse = input

            if skyBoxSettings.userPreferences.improvePrompt && !skyBoxSettings.openAIAPIKey.isEmpty {
                // Improve the prompt using OpenAI
                promptToUse = try await improvePromptWithPreferences(
                    prompt: input,
                    userPreferences: skyBoxSettings.userPreferences,
                    apiKey: skyBoxSettings.openAIAPIKey
                )
            } else if skyBoxSettings.userPreferences.improvePrompt && skyBoxSettings.openAIAPIKey.isEmpty {
                // Play audio if OpenAI API key is missing
                playAudio(audioPlayer: apiKeyMissingPlayer)
                self.skyBoxSettings.userPreferences.improvePrompt = false
            }

            // First model: igorriti/flux-360
            let flux360Model = try await replicate.getModel("igorriti/flux-360")
            if let flux360Version = flux360Model.latestVersion {
                let flux360Prediction = try await replicate.createPrediction(
                    version: flux360Version.id,
                    input: [
                        "model": "dev",
                        "prompt": "\(promptToUse)",
                        "lora_scale": 1,
                        "num_outputs": 1,
                        "aspect_ratio": "3:2",
                        "output_format": "png",
                        "guidance_scale": 3.5,
                        "output_quality": 80,
                        "prompt_strength": 0.8,
                        "extra_lora_scale": 0.8,
                        "num_inference_steps": 28
                    ],
                    wait: true
                )

                // Print the result to the console
                print(flux360Prediction)
                // Corrected the output handling
                guard let fluxOutputArray = flux360Prediction.output?.arrayValue,
                      let fluxImageUrlString = fluxOutputArray.first?.stringValue,
                      let fluxImageUrl = URL(string: fluxImageUrlString) else {
                    throw NSError(domain: "ImageGeneration", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to generate image"])
                }

                // Process image (swap halves)
                let processedImageData = try await processImage(from: fluxImageUrl)

                // Load mask image from app assets
                guard let maskImageData = loadMaskImageFromAssets("mask") else {
                    throw NSError(domain: "ImageProcessing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load mask image"])
                }

                // Second model: vetkastar/fooocus (inpainting)
                let fooocusModel = try await replicate.getModel("vetkastar/fooocus")
                if let fooocusVersion = fooocusModel.latestVersion {
                    let fooocusPrediction = try await replicate.createPrediction(
                        version: fooocusVersion.id,
                        input: [
                            "prompt": "\(promptToUse)",
                            "inpaint_additional_prompt": "\(promptToUse)",
                            "inpaint_input_image": "data:image/png;base64,\(processedImageData.base64EncodedString())",
                            "inpaint_input_mask": "data:image/png;base64,\(maskImageData.base64EncodedString())",
                            "inpaint_strength": 1
                        ],
                        wait: true
                    )

                    // Extract the image URL from the output dictionary
                    if let outputDict = fooocusPrediction.output?.objectValue,
                       let pathsValue = outputDict["paths"],
                       let pathsArray = pathsValue.arrayValue,
                       let inpaintedImageUrlString = pathsArray.first?.stringValue,
                       let inpaintedImageUrl = URL(string: inpaintedImageUrlString) {

                        // Third model: nightmareai/real-esrgan (upscaling)
                        let esrganModel = try await replicate.getModel("nightmareai/real-esrgan")
                        if let esrganVersion = esrganModel.latestVersion {
                            let esrganPrediction = try await replicate.createPrediction(
                                version: esrganVersion.id,
                                input: [
                                    "image": "\(inpaintedImageUrl.absoluteString)",
                                    "scale": 2,
                                    "face_enhance": false
                                ],
                                wait: true
                            )

                            // Corrected the output handling
                            guard let finalImageUrlString = esrganPrediction.output?.stringValue,
                                  let finalImageUrl = URL(string: finalImageUrlString) else {
                                throw NSError(domain: "ImageGeneration", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to upscale image"])
                            }

                            // Update the skybox with the final image
                            self.skyBoxSettings.currentSkybox = finalImageUrl.absoluteString

                            // Save the environment locally
                            try await saveEnvironmentImage(from: finalImageUrl)
                        }
                    } else {
                        throw NSError(domain: "ImageGeneration", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to extract inpainted image URL"])
                    }
                }
            }

        } catch {
            print("Error during prediction: \(error)")
            playAudio(audioPlayer: generationFailedPlayer)
        }
        self.skyBoxSettings.loading = false
    }

    func improvePromptWithPreferences(prompt: String, userPreferences: UserPreferences, apiKey: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let systemPrompt = """
        You are an AI assistant that improves image generation prompts. Try not to include a lot of details; it should be concise and not talk about feelings. You cannot use words like "Landscape".
        The user has the following preferences:
        Style: \(userPreferences.style)
        Things to avoid: \(userPreferences.avoid.joined(separator: ", "))
        Enhance the given prompt to reflect these preferences without changing its core meaning.
        """

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": "Improve this prompt: \(prompt)"]
            ],
            "max_tokens": 50,
            "temperature": 0.7
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "OpenAI", code: 0, userInfo: [NSLocalizedDescriptionKey: errorResponse])
        }

        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        if let choices = json?["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        } else {
            throw NSError(domain: "OpenAI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
    }

    func processImage(from url: URL) async throws -> Data {
        // Implement image processing (swap halves)
        let (data, _) = try await URLSession.shared.data(from: url)
        // Swap the halves of the image
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "ImageProcessing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])
        }

        let size = image.size
        let width = Int(size.width)
        let height = Int(size.height)
        let halfWidth = width / 2

        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            throw NSError(domain: "ImageProcessing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create graphics context"])
        }

        // Flip the context vertically
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // Left half
        let leftRect = CGRect(x: 0, y: 0, width: CGFloat(halfWidth), height: size.height)
        // Right half
        let rightRect = CGRect(x: CGFloat(halfWidth), y: 0, width: size.width - CGFloat(halfWidth), height: size.height)

        // Draw right half on the left
        if let rightHalf = image.cgImage?.cropping(to: CGRect(x: halfWidth, y: 0, width: width - halfWidth, height: height)) {
            context.draw(rightHalf, in: leftRect)
        }

        // Draw left half on the right
        if let leftHalf = image.cgImage?.cropping(to: CGRect(x: 0, y: 0, width: halfWidth, height: height)) {
            context.draw(leftHalf, in: rightRect)
        }

        guard let swappedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            throw NSError(domain: "ImageProcessing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create swapped image"])
        }

        UIGraphicsEndImageContext()

        guard let swappedImageData = swappedImage.pngData() else {
            throw NSError(domain: "ImageProcessing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }

        return swappedImageData
    }

    func loadMaskImageFromAssets(_ imageName: String) -> Data? {
        if let image = UIImage(named: imageName) {
            return image.pngData()
        }
        return nil
    }

    func saveEnvironmentImage(from url: URL) async throws {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "DownloadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to download image"])
        }

        let filename = UUID().uuidString + ".png"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filename)

        try data.write(to: fileURL)

        DispatchQueue.main.async {
            self.skyBoxSettings.savedEnvironments.append(fileURL.path)
        }
    }
}

// Preview Provider
struct SkyBoxControlsView_Previews: PreviewProvider {
    static var previews: some View {
        SkyBoxControlsView().environmentObject(SkyboxSettings())
    }
}
