import SwiftUI

struct ContentView: View {
    @StateObject private var arSession = ARSessionManager()

    var body: some View {
        ZStack {
            ARViewContainer(arSession: arSession)
                .edgesIgnoringSafeArea(.all)
                .accessibilityLabel(
                    "Augmented Reality scene showing clutter transformation"
                )

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

// MARK: - Previews
#if DEBUG
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            let mockSession = ARSessionManager()
            mockSession.isSessionReady = true
            mockSession.sessionProgress = 0.6

            return ContentView()
                .environmentObject(mockSession)
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
    }

    #Preview("AR Session Active") {
        let mockSession = ARSessionManager()
        mockSession.isSessionReady = true
        return ContentView()
            .environmentObject(mockSession)
    }
#endif
