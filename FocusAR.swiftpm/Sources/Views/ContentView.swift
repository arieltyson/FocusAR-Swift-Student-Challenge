import SwiftUI

struct ContentView: View {

    @StateObject private var arSession = ARSessionManager()
        
    var body: some View {
        ZStack {
            ARViewContainer(arSession: arSession)
                .edgesIgnoringSafeArea(.all)
                .accessibilityLabel("Augmented Reality scene showing clutter transformation")
            
            VStack {
                ProgressBar(progress: arSession.sessionProgress)
                    .frame(height: 8)
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                
                Spacer()
                
                if arSession.isSessionReady {
                    Text("Tap cluttered areas to organize them")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                }
            }
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: geometry.size.width * progress)
                    .animation(.linear(duration: 0.2), value: progress)
            }
            .cornerRadius(4)
        }
    }
}
