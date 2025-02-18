import SwiftUI

struct ContentView: View {
    
    @StateObject private var arSession = ARSessionManager()
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(arSession: arSession)
                .edgesIgnoringSafeArea(.all)
                .accessibilityLabel("Augmented Reality scene showing clutter transformation")
            
            // Progress Bar (3-minute timer)
            ProgressBar(progress: $progress)
                .frame(height: 8)
                .padding(.horizontal, 20)
                .padding(.top, 50)
        }
        .onAppear {
            arSession.setupARSession()
        }
    }
}

struct ProgressBar: View {
    @Binding var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundColor(.gray.opacity(0.3))
                .frame(width: geometry.size.width)
                .overlay(
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: geometry.size.width * progress)
                        .animation(.linear(duration: 0.2), alignment: .leading
                )
                .cornerRadius(4)
        }
    }
}
