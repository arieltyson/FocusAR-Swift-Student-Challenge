import SwiftUI

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

// MARK: - Previews
#Preview("Progress Bar (Default)") {
    ProgressBar(progress: 0.42)
        .frame(width: 300, height: 8)
        .padding()
}

#Preview("Progress Bar (Complete)") {
    ProgressBar(progress: 1.0)
        .frame(width: 300, height: 8)
        .padding()
}

#Preview("Progress Bar (Small)") {
    ProgressBar(progress: 0.15)
        .frame(width: 150, height: 4)
}
