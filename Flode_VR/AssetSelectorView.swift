
import SwiftUI

struct AssetSelectorView: View {
    
    // To have access to the object passed to the view
    @EnvironmentObject var skyBoxSettings:SkyboxSettings
    
    var body: some View {
        VStack{
            Text("Welcome to Envi 👋")
                .font(.largeTitle)
                .bold()
            Text("Think beyond your room")
                .font(.title3)
            
            AutoScroller(imageNames: ["anfield", "esteros", "iceland", "fitz", "salinas", "scientific", "airplane", "colon"])
                .padding(.top, 20)
            
            Text("By Flode Labs")
                .font(.footnote)
                .underline()
                .padding(.top, 50)
        }
        .padding(.top, -40)
    }
}

#Preview {
    SkyBoxControlsView()
}

struct SkyBoxButton: View {
    var onClick: () -> Void
    var iconName: String
    var title: String
    
    var body: some View {
        Button(action: onClick, label: {
            Image(systemName: iconName)
                .font(.largeTitle)
            Text(title) // Using short title
                .font(.caption)
        })
    }
}

struct AutoScroller: View {
    var imageNames: [String]
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    @State private var selectedImageIndex: Int = 0
    @EnvironmentObject var skyBoxSettings:SkyboxSettings
    
    var body: some View {
        VStack{
            Text("Choose an example below to discover new places ✨")
            ZStack {
                TabView(selection: $selectedImageIndex) {
                    ForEach(0..<imageNames.count, id: \.self) { index in
                        ZStack(alignment: .topLeading) {
                            Image("\(imageNames[index])")
                                .resizable()
                                .tag(index)
                                .frame(width: 350, height: 200)
                                .onTapGesture {
                                    skyBoxSettings.currentSkybox = imageNames[index]
                                }
                        }
                        .shadow(radius: 20)
                    }
                }
                .frame(height: 220)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .ignoresSafeArea()
                
                HStack {
                    ForEach(0..<imageNames.count, id: \.self) { index in
                        Capsule()
                            .fill(Color.white.opacity(selectedImageIndex == index ? 1 : 0.33))
                            .frame(width: 35, height: 8)
                            .onTapGesture {
                                selectedImageIndex = index
                            }
                    }
                    .offset(y: 130)
                }
                
            }
            .onReceive(timer) { _ in
                withAnimation(.default) {
                    selectedImageIndex = (selectedImageIndex + 1) % imageNames.count
                }
            }
        }
    }
}

