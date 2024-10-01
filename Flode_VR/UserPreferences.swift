
import SwiftUI

class UserPreferences: ObservableObject {
    @Published var style: String = ""
    @Published var avoid: [String] = []
    @Published var improvePrompt: Bool = true
}
