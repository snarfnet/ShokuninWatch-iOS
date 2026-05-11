import SwiftUI

struct LevelView: View {
    @ObservedObject var motionManager: MotionManager

    private let bubbleRadius: CGFloat = 104
    private let dotRadius: CGFloat = 18

    private var bubbleOffset: CGSize {
        let clampedRoll = max(-15, min(15, motionManager.roll))
        let clampedPitch = max(-15, min(15, motionManager.pitch))
        return CGSize(
            width: CGFloat(clampedRoll / 15.0) * bubbleRadius,
            height: CGFloat(clampedPitch / 15.0) * bubbleRadius
        )
    }

    var body: some View {
        ZStack {
            WorkshopBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    ToolHeader(title: "水平器", subtitle: "SITE LEVEL CHECK", icon: "level.fill")

                    WorkshopPanel {
                        VStack(spacing: 18) {
                            LevelDial(
                                bubbleOffset: bubbleOffset,
                                bubbleRadius: bubbleRadius,
                                dotRadius: dotRadius,
                                isLevel: motionManager.isLevel
                            )

                            HStack(spacing: 10) {
                                PrecisionReadout(
                                    label: "ROLL",
                                    value: String(format: "%.1f°", motionManager.roll),
                                    tint: abs(motionManager.roll) < 0.5 ? ShokuninTheme.safetyGreen : ShokuninTheme.amber,
                                    icon: "arrow.left.and.right"
                                )
                                PrecisionReadout(
                                    label: "PITCH",
                                    value: String(format: "%.1f°", motionManager.pitch),
                                    tint: abs(motionManager.pitch) < 0.5 ? ShokuninTheme.safetyGreen : ShokuninTheme.amber,
                                    icon: "arrow.up.and.down"
                                )
                            }

                            LevelStatus(isLevel: motionManager.isLevel)
                        }
                    }
                    .padding(.horizontal, 18)

                    if !AppRuntime.isScreenshotRun {
                        BannerAdView(adUnitID: "ca-app-pub-9404799280370656/5212572496")
                            .frame(height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 18)
                    }
                }
                .padding(.bottom, 24)
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
            RoundedRectangle(cornerRadius: 30)
                .fill(ShokuninTheme.insetMetal)
                .frame(width: 304, height: 304)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(ShokuninTheme.steelBright.opacity(0.22), lineWidth: 1)
                )

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            ShokuninTheme.amber.opacity(0.28),
                            ShokuninTheme.amber.opacity(0.10),
                            Color.black.opacity(0.22)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 250, height: 92)
                .overlay(Capsule().stroke(ShokuninTheme.amber.opacity(0.34), lineWidth: 2))
                .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1).padding(8))
                .rotationEffect(.degrees(-8))

            Circle()
                .stroke(isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.steel.opacity(0.58), lineWidth: 4)
                .frame(width: bubbleRadius * 2, height: bubbleRadius * 2)
                .shadow(color: (isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.amber).opacity(0.25), radius: 14)

            ForEach([0.35, 0.62, 0.86], id: \.self) { scale in
                Circle()
                    .stroke(ShokuninTheme.steel.opacity(0.18), lineWidth: 1)
                    .frame(width: bubbleRadius * 2 * scale, height: bubbleRadius * 2 * scale)
            }

            Rectangle()
                .fill(ShokuninTheme.steel.opacity(0.30))
                .frame(width: 2, height: bubbleRadius * 2)
            Rectangle()
                .fill(ShokuninTheme.steel.opacity(0.30))
                .frame(width: bubbleRadius * 2, height: 2)

            Circle()
                .stroke(ShokuninTheme.amber.opacity(0.75), lineWidth: 2)
                .frame(width: 48, height: 48)
                .overlay(Circle().stroke(Color.black.opacity(0.34), lineWidth: 1).padding(6))

            BubbleDot(isLevel: isLevel)
                .frame(width: dotRadius * 2, height: dotRadius * 2)
                .offset(bubbleOffset)
                .animation(.snappy(duration: 0.10), value: bubbleOffset)

            VStack {
                HStack {
                    Rivet()
                    Spacer()
                    Rivet()
                }
                Spacer()
                HStack {
                    Rivet()
                    Spacer()
                    Rivet()
                }
            }
            .padding(19)
            .frame(width: 304, height: 304)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 316)
    }
}

private struct BubbleDot: View {
    let isLevel: Bool

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.90),
                        (isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.amber).opacity(0.95),
                        (isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.dangerRed).opacity(0.82)
                    ],
                    center: .topLeading,
                    startRadius: 2,
                    endRadius: 25
                )
            )
            .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 2))
            .shadow(color: (isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.dangerRed).opacity(0.70), radius: 15)
    }
}

private struct LevelStatus: View {
    let isLevel: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isLevel ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
            Text(isLevel ? "水平 OK" : "調整中")
        }
        .font(.system(size: 21, weight: .black, design: .rounded))
        .foregroundColor(isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.amber)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(ShokuninTheme.insetMetal)
                .overlay(
                    RoundedRectangle(cornerRadius: 13)
                        .stroke((isLevel ? ShokuninTheme.safetyGreen : ShokuninTheme.amber).opacity(0.46), lineWidth: 1)
                )
        )
    }
}
