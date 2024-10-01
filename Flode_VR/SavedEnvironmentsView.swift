

import SwiftUI

struct SavedEnvironmentsView: View {
    @EnvironmentObject var skyBoxSettings: SkyboxSettings

    var body: some View {
        NavigationView {
            List {
                ForEach(skyBoxSettings.savedEnvironments, id: \.self) { path in
                    HStack {
                        Text(URL(fileURLWithPath: path).lastPathComponent)
                        Spacer()
                        Button("Load") {
                            skyBoxSettings.currentSkybox = path
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Saved Environments")
            .toolbar {
                EditButton()
            }
        }
    }

    func delete(at offsets: IndexSet) {
        skyBoxSettings.savedEnvironments.remove(atOffsets: offsets)
    }
}

// Preview Provider
struct SavedEnvironmentsView_Previews: PreviewProvider {
    static var previews: some View {
        SavedEnvironmentsView()
            .environmentObject(SkyboxSettings())
    }
}
