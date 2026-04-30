import SwiftUI

struct LevelView: View {
    @ObservedObject var motionManager: MotionManager

    private let bubbleRadius: CGFloat = 100
    private let dotRadius: CGFloat = 16

    var bubbleOffset: CGSize {
        let clampedRoll = max(-15, min(15, motionManager.roll))
        let clampedPitch = max(-15, min(15, motionManager.pitch))
        let x = CGFloat(clampedRoll / 15.0) * bubbleRadius
        let y = CGFloat(clampedPitch / 15.0) * bubbleRadius
        return CGSize(width: x, height: y)
    }

    var isLevel: Bool { motionManager.isLevel }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("水平器")
                    .font(.headline)
                    .foregroundColor(.orange)

                ZStack {
                    // Outer circle
                    Circle()
                        .stroke(isLevel ? Color.green : Color.gray, lineWidth: 3)
                        .frame(width: bubbleRadius * 2, height: bubbleRadius * 2)

                    // Center guide
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: bubbleRadius, height: bubbleRadius)

                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: bubbleRadius * 0.4, height: bubbleRadius * 0.4)

                    // Crosshair
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: bubbleRadius * 2)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: bubbleRadius * 2, height: 1)

                    // Bubble dot
                    Circle()
                        .fill(isLevel ? Color.green : Color.red)
                        .frame(width: dotRadius * 2, height: dotRadius * 2)
                        .shadow(color: (isLevel ? Color.green : Color.red).opacity(0.6), radius: 8)
                        .offset(bubbleOffset)
                        .animation(.easeOut(duration: 0.05), value: bubbleOffset)
                }

                HStack(spacing: 40) {
                    VStack(spacing: 4) {
                        Text("水平")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f°", motionManager.roll))
                            .font(.system(size: 24, weight: .semibold, design: .monospaced))
                            .foregroundColor(abs(motionManager.roll) < 0.5 ? .green : .red)
                    }
                    VStack(spacing: 4) {
                        Text("垂直")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f°", motionManager.pitch))
                            .font(.system(size: 24, weight: .semibold, design: .monospaced))
                            .foregroundColor(abs(motionManager.pitch) < 0.5 ? .green : .red)
                    }
                }

                if isLevel {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("水平OK")
                    }
                    .font(.title3)
                    .foregroundColor(.green)
                }

                BannerAdView(adUnitID: "ca-app-pub-9404799280370656/5212572496")
                    .frame(height: 50)
            }
            .padding()
        }
    }
}
