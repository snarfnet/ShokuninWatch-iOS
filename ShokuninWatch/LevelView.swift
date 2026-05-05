import SwiftUI

struct LevelView: View {
    @ObservedObject var motionManager: MotionManager

    private let bubbleRadius: CGFloat = 104
    private let dotRadius: CGFloat = 17

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
            WorkshopBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    ToolHeader(title: "水平器", subtitle: "SITE LEVEL CHECK", icon: "wrench.and.screwdriver.fill")

                    WorkshopPanel {
                        VStack(spacing: 18) {
                            LevelDial(
                                bubbleOffset: bubbleOffset,
                                bubbleRadius: bubbleRadius,
                                dotRadius: dotRadius,
                                isLevel: isLevel
                            )

                            HStack(spacing: 10) {
                                MetricTile(
                                    label: "水平",
                                    value: String(format: "%.1f°", motionManager.roll),
                                    tint: abs(motionManager.roll) < 0.5 ? ShokuninTheme.safetyGreen : ShokuninTheme.dangerRed
                                )
                                MetricTile(
                                    label: "垂直",
                                    value: String(format: "%.1f°", motionManager.pitch),
                                    tint: abs(motionManager.pitch) < 0.5 ? ShokuninTheme.safetyGreen : ShokuninTheme.dangerRed
                                )
                            }

                            HStack(spacing: 10) {
                                Image(systemName: isLevel ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                                Text(isLevel ? "水平OK" : "調整中")
                            }
                            .font(.system(size: 21, weight: .black))
                            .foregroundColor(isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.amber)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.28))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke((isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.amber).opacity(0.45), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 18)

                    BannerAdView(adUnitID: "ca-app-pub-9404799280370656/5212572496")
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 18)
                }
                .padding(.bottom, 26)
            }
        }
    }
}

private struct LevelDial: View {
    let bubbleOffset: CGSize
    let bubbleRadius: CGFloat
    let dotRadius: CGFloat
    let isLevel: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.black.opacity(0.28))
                .frame(width: 292, height: 292)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(ShokuninTheme.steel.opacity(0.38), lineWidth: 1)
                )

            Circle()
                .stroke(isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.steel.opacity(0.58), lineWidth: 4)
                .frame(width: bubbleRadius * 2, height: bubbleRadius * 2)
                .shadow(color: (isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.amber).opacity(0.28), radius: 12)

            ForEach([0.40, 0.70, 1.00], id: \.self) { scale in
                Circle()
                    .stroke(ShokuninTheme.steel.opacity(scale == 1.0 ? 0.0 : 0.20), lineWidth: 1)
                    .frame(width: bubbleRadius * 2 * scale, height: bubbleRadius * 2 * scale)
            }

            Rectangle()
                .fill(ShokuninTheme.steel.opacity(0.28))
                .frame(width: 2, height: bubbleRadius * 2)
            Rectangle()
                .fill(ShokuninTheme.steel.opacity(0.28))
                .frame(width: bubbleRadius * 2, height: 2)

            Circle()
                .stroke(ShokuninTheme.amber.opacity(0.60), lineWidth: 2)
                .frame(width: 46, height: 46)

            Circle()
                .fill(isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.dangerRed)
                .frame(width: dotRadius * 2, height: dotRadius * 2)
                .overlay(Circle().stroke(Color.white.opacity(0.45), lineWidth: 2))
                .shadow(color: (isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.dangerRed).opacity(0.72), radius: 14)
                .offset(bubbleOffset)
                .animation(.easeOut(duration: 0.05), value: bubbleOffset)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}
