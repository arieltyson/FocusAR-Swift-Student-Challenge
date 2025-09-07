import SwiftUI

#if canImport(Lottie)
    import Lottie

    struct LottieView: UIViewRepresentable {
        let name: String
        let loopMode: LottieLoopMode
        let speed: CGFloat

        func makeUIView(context: Context) -> LottieAnimationView {
            let v = LottieAnimationView(name: name)
            v.loopMode = loopMode
            v.animationSpeed = speed
            v.contentMode = .scaleAspectFit
            v.play()
            return v
        }

        func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
    }
#endif
